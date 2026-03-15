import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/alumno.dart';
import '../models/usuario.dart';
import '../models/tipo_reporte.dart';
import '../models/reporte.dart';
import '../services/alumno_service.dart';
import '../services/usuario_service.dart';
import '../services/tipo_reporte_service.dart';
import '../services/reporte_service.dart';
import '../config/api_config.dart';
import '../config/global.dart';

class ReporteFormScreen extends StatefulWidget {
  final Reporte? reporte;
  ReporteFormScreen({this.reporte});

  @override
  _ReporteFormScreenState createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _accionesController = TextEditingController();
  final _alumnoFiltroCtrl = TextEditingController();
  DateTime? _fechaIncidencia;

  List<Alumno> _alumnos = [];
  List<Alumno> _alumnosFiltrados = [];
  List<Usuario> _usuarios = [];
  List<TipoReporte> _tipos = [];

  Alumno? _alumnoSeleccionado;
  Usuario? _usuarioSeleccionado;
  TipoReporte? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _alumnoFiltroCtrl.addListener(_aplicarFiltroAlumno);
  }

  Future<void> _cargarDatos() async {
    final alumnos = await AlumnoService().obtenerAlumnos();
    final usuarios = await UsuarioService().obtenerUsuarios();
    final tipos = await TipoReporteService().obtenerTipos();

    setState(() {
      _alumnos = alumnos;
      _alumnosFiltrados = List.from(alumnos);
      _usuarios = usuarios;
      _tipos = tipos;
    });
  }

  void _aplicarFiltroAlumno() {
    final q = _alumnoFiltroCtrl.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _alumnosFiltrados = List.from(_alumnos);
      } else {
        _alumnosFiltrados = _alumnos.where((a) {
          final full = '${a.nombre} ${a.apaterno} ${a.amaterno} ${a.matricula}'.toLowerCase();
          return full.contains(q);
        }).toList();
      }
      if (_alumnoSeleccionado != null) {
        final existe = _alumnosFiltrados.any((a) => a.id == _alumnoSeleccionado!.id);
        if (!existe) _alumnoSeleccionado = null;
      }
    });
  }

  void _guardar() async {
    if (_formKey.currentState!.validate() &&
        _alumnoSeleccionado != null &&
        _usuarioSeleccionado != null &&
        _tipoSeleccionado != null &&
        _fechaIncidencia != null) {
      final nuevo = Reporte(
        id: 0,
        folio: '', // Se autogenera en backend
        descripcionHechos: _descripcionController.text,
        accionesTomadas: _accionesController.text,
        fechaIncidencia: _fechaIncidencia!.toIso8601String(),
        fechaCreacion: '', // Se autogenera en backend
        estatus: 'Abierto',
        alumno: _alumnoSeleccionado!,
        usuario: _usuarioSeleccionado!,
        tipoReporte: _tipoSeleccionado!,
      );

      try {
        await ReporteService().crearReporte(nuevo);

        // Mostrar diálogo de confirmación antes de cerrar pantalla
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reporte guardado'),
            content: const Text('El reporte se guardó correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pop(context); // cerrar pantalla de formulario
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el reporte: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _alumnoFiltroCtrl.removeListener(_aplicarFiltroAlumno);
    _alumnoFiltroCtrl.dispose();
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
        title: Text('Nuevo Reporte de Incidencia', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _alumnos.isEmpty || _usuarios.isEmpty || _tipos.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // campo de búsqueda para filtrar alumnos
                    TextField(
                      controller: _alumnoFiltroCtrl,
                      decoration: InputDecoration(
                        labelText: 'Buscar alumno (nombre o matrícula)',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown Alumno (usa la lista filtrada)
                    DropdownButtonFormField<Alumno>(
                      value: _alumnoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Alumno *',
                        hintText: 'Campo obligatorio',
                      ),
                      items: _alumnosFiltrados.map((a) {
                        return DropdownMenuItem(
                          value: a,
                          child: Text('${a.nombre} ${a.apaterno} ${a.amaterno}'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _alumnoSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un alumno' : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<Usuario>(
                      value: _usuarioSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Usuario que reporta *',
                        hintText: 'Campo obligatorio',
                      ),
                      items: _usuarios.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text('${u.nombre} ${u.apaterno} (${u.rol})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _usuarioSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un usuario' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TipoReporte>(
                      value: _tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo de reporte *',
                        hintText: 'Campo obligatorio',
                      ),
                      items: _tipos.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text('${t.nombre} (${t.gravedad})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _tipoSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un tipo' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción de los hechos *',
                        hintText: 'Campo obligatorio',
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accionesController,
                      decoration: InputDecoration(labelText: 'Acciones tomadas'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(_fechaIncidencia == null
                          ? 'Selecciona fecha de incidencia *'
                          : 'Fecha: ${DateFormat.yMMMMd('es').format(_fechaIncidencia!)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaIncidencia ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          locale: const Locale('es', 'ES'),
                        );
                        if (fecha != null) setState(() => _fechaIncidencia = fecha);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: 'Abierto',
                      decoration: InputDecoration(labelText: 'Estatus'),
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: Text('Guardar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
