import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../models/grupo.dart';
import '../services/alumno_service.dart';
import '../services/grupo_service.dart';
import 'package:intl/intl.dart';

class AlumnoFormScreen extends StatefulWidget {
  final Alumno? alumno;
  AlumnoFormScreen({this.alumno});

  @override
  _AlumnoFormScreenState createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends State<AlumnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apaternoController = TextEditingController();
  final _amaternoController = TextEditingController();
  final _fechaController = TextEditingController();
  Grupo? _grupoSeleccionado;
  List<Grupo> _grupos = [];
  String _sexo = 'O';

  final _alumnoService = AlumnoService();
  final _grupoService = GrupoService();

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
    if (widget.alumno != null) {
      // si el modelo tiene campos no-null, usar directos; sino usar ?? ''
      _matriculaController.text = widget.alumno!.matricula ?? '';
      _nombreController.text = widget.alumno!.nombre;
      _apaternoController.text = widget.alumno!.apaterno;
      _amaternoController.text = widget.alumno!.amaterno ?? '';
      _fechaController.text = widget.alumno!.fechaNacimiento ?? '';
      _sexo = widget.alumno!.sexo ?? 'O';
      _grupoSeleccionado = widget.alumno!.grupo;
    }
  }

  void _inicializarFormulario() async {
    final lista = await _grupoService.obtenerGrupos();
    Grupo grupoInicial;
    if (widget.alumno != null && widget.alumno!.grupo != null) {
      grupoInicial = lista.firstWhere(
        (g) => g.id == widget.alumno!.grupo!.id,
        orElse: () => lista.isNotEmpty
            ? lista.first
            : Grupo(id: 0, descripcion: '', grado: 0, ciclo: '', idTutor: 0),
      );
    } else {
      grupoInicial = lista.isNotEmpty
          ? lista.first
          : Grupo(id: 0, descripcion: '', grado: 0, ciclo: '', idTutor: 0);
    }
    setState(() {
      _grupos = lista;
      // si no hay grupos reales, mantener null para forzar selección
      _grupoSeleccionado = lista.isNotEmpty ? grupoInicial : null;
    });
  }

  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      final formato = DateFormat('yyyy-MM-dd');
      setState(() {
        _fechaController.text = formato.format(fecha);
      });
    }
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_grupoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecciona un grupo')));
      return;
    }

    // si el modelo espera valores no-null, se usan assert/checked values
    final nuevo = Alumno(
      id: widget.alumno?.id ?? 0,
      matricula: _matriculaController.text,
      nombre: _nombreController.text,
      apaterno: _apaternoController.text,
      amaterno: _amaternoController.text,
      fechaNacimiento: _fechaController.text,
      grupo: _grupoSeleccionado!, // validado arriba
      sexo: _sexo,
    );

    try {
      if (widget.alumno == null) {
        await _alumnoService.crearAlumno(nuevo);
      } else {
        await _alumnoService.editarAlumno(nuevo);
      }

      // Mostrar diálogo de confirmación
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.alumno == null ? 'Alumno creado' : 'Alumno actualizado'),
          content: Text(widget.alumno == null 
              ? 'El alumno se creó correctamente.' 
              : 'El alumno se actualizó correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el alumno: $e')),
      );
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _nombreController.dispose();
    _apaternoController.dispose();
    _amaternoController.dispose();
    _fechaController.dispose();
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
        title: Text(
          widget.alumno == null ? 'Nuevo Alumno' : 'Editar Alumno',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matrícula *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apaternoController,
                decoration: InputDecoration(
                  labelText: 'Apellido Paterno *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _amaternoController,
                decoration: InputDecoration(labelText: 'Apellido Materno'),
              ),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento *',
                  hintText: 'Campo obligatorio',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<Grupo>(
                value: _grupoSeleccionado,
                items: _grupos.map((g) => DropdownMenuItem(value: g, child: Text('${g.descripcion} • ${g.grado}° • ${g.ciclo}'))).toList(),
                onChanged: (grupo) => setState(() => _grupoSeleccionado = grupo),
                decoration: InputDecoration(
                  labelText: 'Grupo *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => value == null ? 'Selecciona un grupo' : null,
              ),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(
                  labelText: 'Sexo *',
                  hintText: 'Campo obligatorio',
                ),
                items: [
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  DropdownMenuItem(value: 'O', child: Text('Otro / No especificado')),
                ],
                onChanged: (v) => setState(() => _sexo = v ?? 'O'),
                validator: (v) => (v == null || v.isEmpty) ? 'Seleccione sexo' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: Text(widget.alumno == null ? 'Guardar' : 'Actualizar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}