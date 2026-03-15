import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:developer' as developer;
import '../models/alumno.dart';
import '../services/alumno_service.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';
import 'alumno_form_screen.dart';
import '../config/api_config.dart';
import '../config/global.dart';
import 'package:path_provider/path_provider.dart';

class AlumnosScreen extends StatefulWidget {
  @override
  _AlumnosScreenState createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  final _service = AlumnoService();
  // Inicializa para que el FutureBuilder no intente leer una variable no inicializada
  Future<List<Alumno>> _alumnos = Future.value([]);
  List<Alumno> _todos = [];

  final _grupoService = GrupoService();
  List<Grupo> _grupos = [];
  Grupo? _filtroGrupo;
  bool _uploading = false;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    try {
      final g = await _grupoService.obtenerGrupos();
      setState(() {
        _grupos = g;
      });
    } catch (e) {
      // opcional: manejar error
    }
  }

  Future<void> _cargarAlumnos() async {
    final lista = await _service.obtenerAlumnos();
    setState(() {
      _todos = lista;
      _aplicarFiltro(); // inicializa _alumnos acorde al filtro actual
    });
  }

  void _aplicarFiltro() {
    if (_filtroGrupo == null) {
      _alumnos = Future.value(_todos);
    } else {
      final filtrados = _todos.where((a) => a.grupo?.id == _filtroGrupo!.id).toList();
      _alumnos = Future.value(filtrados);
    }
  }

  Future<void> _pickAndUploadExcel() async {
    // Si quieres seguir permitiendo import desde diálogo en móvil/escritorio
    final fs.XTypeGroup group = fs.XTypeGroup(label: 'excel', extensions: ['xlsx', 'xls']);
    final fs.XFile? picked = await fs.openFile(acceptedTypeGroups: [group]);
    if (picked == null) return;
    final fileBytes = await picked.readAsBytes();
    final fileName = picked.name;

    // marcar busy global y estado local de upload (icono)
    setBusy(true);
    setState(() {
      _uploading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subiendo ${fileName}...')));

    try {
      final uri = Uri.parse('$apiBaseUrl/importar-alumnos');
      final request = http.MultipartRequest('POST', uri);
      if (jwtToken != null && jwtToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $jwtToken';
      }

      // determinar contentType por extensión
      String lower = fileName.toLowerCase();
      final contentType = lower.endsWith('.xls')
          ? MediaType('application', 'vnd.ms-excel')
          : MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');

      developer.log('Subiendo desde bytes (file_selector). name=$fileName size=${fileBytes.length}', name: 'AlumnosScreen');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: contentType,
      ));

      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      developer.log('ImportarAlumnos response: ${streamed.statusCode} -> $respStr', name: 'AlumnosScreen');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Importación exitosa')));
        await _cargarAlumnos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error import: ${streamed.statusCode}')));
      }
    } catch (e, st) {
      developer.log('Error al subir Excel: $e', name: 'AlumnosScreen', error: e, stackTrace: st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    } finally {
      // quitar busy global y estado local
      setBusy(false);
      setState(() {
        _uploading = false;
      });
    }
  }

  void _refrescar() {
    _cargarAlumnos();
  }

  void _eliminar(int id) async {
    setBusy(true);
    try {
      await _service.eliminarAlumno(id);
      _cargarAlumnos();
    } finally {
      setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // flecha de regreso en blanco
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Alumnos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: _uploading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(Icons.file_upload),
            onPressed: _uploading ? null : _pickAndUploadExcel,
            tooltip: 'Importar Excel',
          ),
          IconButton(
            icon: _exporting ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.share),
            onPressed: _exporting ? null : _mostrarOpcionesExportar,
            tooltip: 'Exportar',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AlumnoFormScreen()));
              _refrescar();
            },
            tooltip: 'Nuevo alumno',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // filtros por grupo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Grupo?>(
                      value: _filtroGrupo,
                      decoration: InputDecoration(labelText: 'Filtrar por grupo'),
                      items: [
                        DropdownMenuItem<Grupo?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._grupos.map((g) => DropdownMenuItem<Grupo?>(
                          value: g,
                          child: Text('${g.descripcion} - ${g.grado}° (${g.ciclo})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroGrupo = value;
                          _aplicarFiltro();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroGrupo = null;
                        _aplicarFiltro();
                      });
                    },
                    child: Text('Limpiar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Alumno>>(
                future: _alumnos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final alumnos = snapshot.data!;
                    return ListView.builder(
                      itemCount: alumnos.length,
                      itemBuilder: (context, index) {
                        final a = alumnos[index];
                        return ListTile(
                          title: Text('${a.nombre} ${a.apaterno}'),
                          subtitle: Text('Grupo: ${a.grupo?.descripcion ?? 'Sin grupo'} • Ciclo: ${a.grupo?.ciclo ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AlumnoFormScreen(alumno: a)),
                                  ).then((_) => _refrescar());
                                },
                              ),
                              IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(a.id ?? 0)),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AlumnoFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarOpcionesExportar() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Exportar listado (PDF)'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarListadoPdf();
                },
              ),
              ListTile(
                leading: Icon(Icons.grid_on),
                title: Text('Exportar listado (CSV)'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarListadoCsv();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportarListadoPdf() async {
    setState(() => _exporting = true);
    try {
      final doc = pw.Document();
      final List<Alumno> lista = _filtroGrupo == null ? _todos : _todos.where((a) => a.grupo?.id == _filtroGrupo!.id).toList();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return [
              pw.Header(level: 0, child: pw.Text('Listado de Alumnos', style: pw.TextStyle(fontSize: 18))),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Nombre', 'Apellido', 'Grupo', 'Ciclo'],
                data: lista.map((a) => [
                  a.nombre ?? '',
                  a.apaterno ?? '',
                  a.grupo?.descripcion ?? '',
                  a.grupo?.ciclo ?? ''
                ]).toList(),
              ),
            ];
          },
        ),
      );
      final bytes = await doc.save();
      await _guardarBytesComoArchivo(bytes, 'listado_alumnos.pdf');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF generado y guardado')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exportando PDF: $e')));
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<void> _exportarListadoCsv() async {
    setState(() => _exporting = true);
    try {
      final lista = _filtroGrupo == null ? _todos : _todos.where((a) => a.grupo?.id == _filtroGrupo!.id).toList();
      final sb = StringBuffer();
      sb.writeln('Nombre,Apellido,Grupo,Ciclo');
      for (final a in lista) {
        final row = [
          (a.nombre ?? '').replaceAll('"', '""'),
          (a.apaterno ?? '').replaceAll('"', '""'),
          (a.grupo?.descripcion ?? '').replaceAll('"', '""'),
          (a.grupo?.ciclo ?? '').replaceAll('"', '""'),
        ];
        sb.writeln('"${row.join('","')}"');
      }
      final bytes = utf8.encode(sb.toString());
      await _guardarBytesComoArchivo(Uint8List.fromList(bytes), 'listado_alumnos.csv');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV generado y guardado')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exportando CSV: $e')));
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<void> _guardarBytesComoArchivo(Uint8List bytes, String suggestedName) async {
    try {
      // Directorio por defecto (app documents). En Android intenta usar external si existe.
      Directory dir = await getApplicationDocumentsDirectory();
      if (Platform.isAndroid) {
        final external = await getExternalStorageDirectory();
        if (external != null) dir = external;
      }

      final filePath = '${dir.path}/$suggestedName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo guardado en $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo guardar el archivo: $e')));
    }
  }
}
