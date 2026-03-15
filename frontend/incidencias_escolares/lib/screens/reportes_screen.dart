import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../models/alumno.dart';
import '../models/tipo_reporte.dart';
import '../services/reporte_service.dart';
import '../services/alumno_service.dart';
import '../services/tipo_reporte_service.dart';
import 'reporte_form_screen.dart';
import 'reporte_detail_screen.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _service = ReporteService();
  Future<List<Reporte>> _reportes = Future.value([]);
  List<Reporte> _todos = [];

  List<Alumno> _alumnos = [];
  List<Alumno> _alumnosFiltrados = [];
  List<TipoReporte> _tipos = [];
  final List<String> _estatuses = ['Abierto', 'En Seguimiento', 'Cerrado'];

  // 🔧 CAMBIO: Usar ID en lugar del objeto completo
  int? _filtroAlumnoId;  // Cambio aquí
  int? _filtroTipoId;    // Cambio aquí (opcional para consistencia)
  String? _filtroEstatus;

  final TextEditingController _alumnoBusquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _alumnoBusquedaCtrl.addListener(_aplicarFiltroAlumnos);
  }

  Future<void> _cargarDatos() async {
    final reportes = await _service.obtenerReportes();
    final alumnos = await AlumnoService().obtenerAlumnos();
    final tipos = await TipoReporteService().obtenerTipos();

    setState(() {
      _todos = reportes;
      _reportes = Future.value(reportes);
      
      // 🔧 CAMBIO: Eliminar duplicados basándose en ID
      final alumnosUnicos = <int, Alumno>{};
      for (var alumno in alumnos) {
        alumnosUnicos[alumno.id] = alumno;
      }
      _alumnos = alumnosUnicos.values.toList();
      _alumnosFiltrados = List.from(_alumnos);
      
      final tiposUnicos = <int, TipoReporte>{};
      for (var tipo in tipos) {
        tiposUnicos[tipo.id] = tipo;
      }
      _tipos = tiposUnicos.values.toList();
    });

    print('📋 Reportes cargados:');
    for (var r in reportes) {
      print('Folio: ${r.folio}, Alumno: ${r.alumno.id} ${r.alumno.nombre} ${r.alumno.apaterno}, Tipo: ${r.tipoReporte.id} ${r.tipoReporte.nombre}, Estatus: ${r.estatus}');
    }
  }

  void _aplicarFiltroAlumnos() {
    final q = _alumnoBusquedaCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _alumnosFiltrados = List.from(_alumnos);
      } else {
        _alumnosFiltrados = _alumnos.where((a) {
          final full = '${a.nombre} ${a.apaterno} ${a.amaterno} ${a.matricula}'.toLowerCase();
          return full.contains(q);
        }).toList();
      }
      
      // 🔧 CAMBIO: Verificar si el ID seleccionado sigue existiendo
      if (_filtroAlumnoId != null) {
        final existe = _alumnosFiltrados.any((a) => a.id == _filtroAlumnoId);
        if (!existe) _filtroAlumnoId = null;
      }
    });
  }

  void _filtrar() {
    final idAlumno = _filtroAlumnoId;
    final idTipo = _filtroTipoId;
    final estatus = _filtroEstatus;

    final filtrados = _todos.where((r) {
      final coincideAlumno = idAlumno == null || r.alumno.id == idAlumno;
      final coincideTipo = idTipo == null || r.tipoReporte.id == idTipo;
      final coincideEstatus = estatus == null || r.estatus == estatus;

      return coincideAlumno && coincideTipo && coincideEstatus;
    }).toList();

    setState(() {
      _reportes = Future.value(filtrados);
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroAlumnoId = null;
      _filtroTipoId = null;
      _filtroEstatus = null;
      _alumnoBusquedaCtrl.clear();
      _alumnosFiltrados = List.from(_alumnos);
      _reportes = Future.value(_todos);
    });
  }

  @override
  void dispose() {
    _alumnoBusquedaCtrl.removeListener(_aplicarFiltroAlumnos);
    _alumnoBusquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Reportes de Incidencia', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _alumnoBusquedaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar alumno',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),

                // 🔧 SOLUCIÓN: Dropdown con IDs únicos
                DropdownButtonFormField<int>(
                  value: _filtroAlumnoId,
                  decoration: InputDecoration(labelText: 'Filtrar por alumno'),
                  items: _alumnosFiltrados.map((a) {
                    return DropdownMenuItem<int>(
                      value: a.id,  // Usar ID único
                      child: Text('${a.nombre} ${a.apaterno}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroAlumnoId = value);
                    _filtrar();
                  },
                ),
                
                const SizedBox(height: 8),
                
                // 🔧 SOLUCIÓN: También aplicar a TipoReporte para consistencia
                DropdownButtonFormField<int>(
                  value: _filtroTipoId,
                  decoration: InputDecoration(labelText: 'Filtrar por tipo de reporte'),
                  items: _tipos.map((t) {
                    return DropdownMenuItem<int>(
                      value: t.id,  // Usar ID único
                      child: Text(t.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroTipoId = value);
                    _filtrar();
                  },
                ),
                
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _filtroEstatus,
                  decoration: InputDecoration(labelText: 'Filtrar por estatus'),
                  items: _estatuses.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroEstatus = value);
                    _filtrar();
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _limpiarFiltros,
                  child: Text('Restablecer filtros'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reporte>>(
              future: _reportes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los reportes'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay reportes registrados'));
                }

                final reportes = snapshot.data!;
                return ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final r = reportes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('Folio: ${r.folio}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alumno: ${r.alumno.nombre} ${r.alumno.apaterno}'),
                            Text('Tipo: ${r.tipoReporte.nombre} (${r.tipoReporte.gravedad})'),
                            Text('Fecha: ${r.fechaIncidencia.split(' ')[0]}'),
                            Text('Estatus: ${r.estatus}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward),
                          tooltip: 'Ver detalle',
                          onPressed: () async {
                            final actualizado = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ReporteDetailScreen(reporte: r)),
                            );
                            if (actualizado == true) {
                              await _cargarDatos();
                            }
                          },
                        ),
                        onTap: () async {
                          final actualizado = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReporteDetailScreen(reporte: r)),
                          );
                          if (actualizado == true) {
                            await _cargarDatos();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final creado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReporteFormScreen()),
          );
          if (creado == true) {
            await _cargarDatos();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        tooltip: 'Crear nuevo reporte',
      ),
    );
  }
}
