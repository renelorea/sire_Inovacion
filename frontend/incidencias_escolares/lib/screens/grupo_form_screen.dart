import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/grupo.dart';
import '../services/grupo_service.dart';
import '../config/api_config.dart';
import '../config/global.dart';

class GrupoFormScreen extends StatefulWidget {
  final Grupo? grupo;
  GrupoFormScreen({this.grupo});

  @override
  _GrupoFormScreenState createState() => _GrupoFormScreenState();
}

class _GrupoFormScreenState extends State<GrupoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _gradoController = TextEditingController();
  final _cicloController = TextEditingController();
  final _tutorController = TextEditingController(); // preservado como fallback
  final _service = GrupoService();

  // lista de profesores y tutor seleccionado (id como String)
  List<Map<String, dynamic>> _profesores = [];
  String? _tutorSeleccionadoId;
  bool _loadingProfesores = false;

  @override
  void initState() {
    super.initState();
    if (widget.grupo != null) {
      _descripcionController.text = widget.grupo!.descripcion;
      _gradoController.text = widget.grupo!.grado.toString();
      _cicloController.text = widget.grupo!.ciclo;
      _tutorController.text = widget.grupo!.idTutor.toString();
      _tutorSeleccionadoId = widget.grupo!.idTutor != 0 ? widget.grupo!.idTutor.toString() : null;
    }
    _cargarProfesores();
  }

  Future<void> _cargarProfesores() async {
    if (jwtToken == null) return;
    setState(() => _loadingProfesores = true);
    try {
      final uri = Uri.parse('$apiBaseUrl/usuarios').replace(queryParameters: {'rol': 'profesor'});
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is List) {
          setState(() {
            _profesores = data.map((e) => e as Map<String, dynamic>).toList();
            // mantener _tutorSeleccionadoId si ya venía del grupo
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando profesores (${resp.statusCode})')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando profesores: $e')));
    } finally {
      setState(() => _loadingProfesores = false);
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Grupo(
        id: widget.grupo?.id ?? 0,
        descripcion: _descripcionController.text,
        grado: int.tryParse(_gradoController.text) ?? 0,
        ciclo: _cicloController.text,
        idTutor: int.tryParse(_tutorSeleccionadoId ?? _tutorController.text) ?? 0,
      );

      try {
        if (widget.grupo == null) {
          await _service.crearGrupo(nuevo);
        } else {
          await _service.editarGrupo(nuevo);
        }

        // Mostrar diálogo de confirmación
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.grupo == null ? 'Grupo creado' : 'Grupo actualizado'),
            content: Text(widget.grupo == null 
                ? 'El grupo se creó correctamente.' 
                : 'El grupo se actualizó correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el grupo: $e')),
        );
      }
    }
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
          widget.grupo == null ? 'Nuevo Grupo' : 'Editar Grupo',
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
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _gradoController,
                decoration: InputDecoration(
                  labelText: 'Grado *',
                  hintText: 'Campo obligatorio',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cicloController,
                decoration: InputDecoration(
                  labelText: 'Ciclo Escolar *',
                  hintText: 'Campo obligatorio',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              // Dropdown de tutores (profesores)
              _loadingProfesores
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String?>(
                      value: _tutorSeleccionadoId,
                      decoration: const InputDecoration(
                        labelText: 'Tutor (Profesor) *',
                        hintText: 'Campo obligatorio',
                      ),
                      items: <DropdownMenuItem<String?>>[
                        const DropdownMenuItem<String?>(value: null, child: Text('-- Ninguno --')),
                        ..._profesores.map((p) {
                          final idStr = (p['id'] ?? p['id_usuario'] ?? p['id_profesor'])?.toString();
                          final label = '${p['nombre'] ?? ''} ${p['apellido_paterno'] ?? ''} ${p['apellido_materno'] ?? ''}'.trim();
                          return DropdownMenuItem<String?>(
                            value: idStr,
                            child: Text(label.isEmpty ? (p['email']?.toString() ?? 'Profesor') : label),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? v) => setState(() => _tutorSeleccionadoId = v),
                      validator: (value) {
                        // si hay profesores disponibles, exigir selección; si no, permitir vacío
                        if (_profesores.isNotEmpty && (value == null || value.isEmpty)) {
                          return 'Selecciona un tutor';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 20),
              widget.grupo == null
                ? ElevatedButton(onPressed: _guardar, child: Text('Guardar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))
                : ElevatedButton(onPressed: _guardar, child: Text('Actualizar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
