import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../config/global.dart';
import '../services/reporte_service.dart';

class ReporteIncidenciasScreen extends StatefulWidget {
  const ReporteIncidenciasScreen({Key? key}) : super(key: key);

  @override
  State<ReporteIncidenciasScreen> createState() => _ReporteIncidenciasScreenState();
}

class _ReporteIncidenciasScreenState extends State<ReporteIncidenciasScreen> {
  final TextEditingController _emailCtrl = TextEditingController();

  bool _loading = false;
  List<dynamic> _resultados = [];

  List<Map<String, dynamic>> _grupos = [];
  Map<String, dynamic>? _grupoSeleccionado;

  // lista de alumnos del grupo seleccionado
  List<Map<String, dynamic>> _alumnosDelGrupo = [];
  // ahora guardamos sólo el id seleccionado (String) para evitar duplicados en Dropdown
  String? _alumnoSeleccionadoId;

  final ReporteService _reporteService = ReporteService();

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    if (jwtToken == null) return;
    try {
      final uri = Uri.parse('$apiBaseUrl/grupos');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is List) {
          setState(() {
            _grupos = data.map((e) => e as Map<String, dynamic>).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando grupos (${resp.statusCode})')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando grupos: $e')));
    }
  }

  Future<void> _cargarAlumnosDelGrupo(String grupoId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/grupos/$grupoId/alumnos');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is List) {
          setState(() {
            _alumnosDelGrupo = data.map((e) => e as Map<String, dynamic>).toList();
            _alumnoSeleccionadoId = null;
          });
          return;
        }
      }
      // fallback
      final fallback = Uri.parse('$apiBaseUrl/alumnos').replace(queryParameters: {'grupo': grupoId});
      final resp2 = await http.get(fallback, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });
      if (resp2.statusCode == 200) {
        final data = json.decode(resp2.body);
        if (data is List) {
          setState(() {
            _alumnosDelGrupo = data.map((e) => e as Map<String, dynamic>).toList();
            _alumnoSeleccionadoId = null;
          });
        }
      } else {
        setState(() {
          _alumnosDelGrupo = [];
          _alumnoSeleccionadoId = null;
        });
      }
    } catch (e) {
      setState(() {
        _alumnosDelGrupo = [];
        _alumnoSeleccionadoId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando alumnos del grupo: $e')));
    }
  }

  Future<void> _buscar({bool enviarEmail = false}) async {
    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final grupoId = _grupoSeleccionado != null
          ? (_grupoSeleccionado!['id_grupo'] ?? _grupoSeleccionado!['id'])?.toString()
          : null;

      final alumnoId = _alumnoSeleccionadoId;

      Map<String, String>? alumnoData;
      if (alumnoId != null) {
        final sel = _alumnosDelGrupo.firstWhere(
            (a) => (a['id'] ?? a['id_alumno'])?.toString() == alumnoId,
            orElse: () => <String, dynamic>{});
        if (sel.isNotEmpty) {
          alumnoData = {
            'id': (sel['id'] ?? sel['id_alumno'])?.toString() ?? '',
            'nombre': (sel['nombres'] ?? sel['nombre'])?.toString() ?? '',
            'apellido_paterno': (sel['apellido_paterno'] ?? '')?.toString() ?? '',
            'apellido_materno': (sel['apellido_materno'] ?? '')?.toString() ?? '',
            'matricula': (sel['matricula'] ?? '')?.toString() ?? '',
          };
        }
      } else {
        alumnoData = null;
      }

      final result = await _reporteService.consultar(
        grupo: grupoId,
        alumno: alumnoId,
        alumnoData: alumnoData,
        email: enviarEmail && _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
      );

      if (enviarEmail && result is Map && result.containsKey('msg')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['msg'].toString())));
      } else if (result is List) {
        setState(() => _resultados = result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuesta inesperada del servidor')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildItem(dynamic r) {
    final alumno = r['alumno'] ?? {};
    final grupo = alumno['grupo'] ?? {};
    return ListTile(
      title: Text('${alumno['nombre'] ?? ''} ${alumno['apellido_paterno'] ?? ''} ${alumno['apellido_materno'] ?? ''}'),
      subtitle: Text('Folio: ${r['folio'] ?? ''}  ·  Grupo: ${grupo['grupo'] ?? grupo['id_grupo'] ?? ''}'),
      trailing: Text(r['estatus'] ?? ''),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Detalle reporte'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Folio: ${r['folio'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Fecha incidencia: ${r['fecha_incidencia'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Estatus: ${r['estatus'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Descripción: ${r['descripcion_hechos'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Acciones: ${r['acciones_tomadas'] ?? ''}'),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text('Envio de reportes', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Dropdown grupos
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _grupoSeleccionado,
            decoration: const InputDecoration(labelText: 'Grupo'),
            items: _grupos.map((g) {
              final label = g['Descripcion'] ?? g['grupo'] ?? g['nombre'] ?? 'Grupo ${g['id_grupo'] ?? g['id'] ?? ''}';
              return DropdownMenuItem<Map<String, dynamic>>(
                value: g,
                child: Text(label.toString()),
              );
            }).toList(),
            onChanged: (v) async {
              setState(() {
                _grupoSeleccionado = v;
                _alumnosDelGrupo = [];
                _alumnoSeleccionadoId = null;
              });
              final gid = v != null ? (v['id_grupo'] ?? v['id'])?.toString() : null;
              if (gid != null) await _cargarAlumnosDelGrupo(gid);
            },
            isExpanded: true,
          ),
          const SizedBox(height: 8),
          // Si hay alumnos del grupo, mostrar dropdown para seleccionar alumno (incluye opción vacía)
          if (_alumnosDelGrupo.isNotEmpty) ...[
            // ahora Dropdown usa el id (String) como value para garantizar unicidad
            DropdownButtonFormField<String?>(
              value: _alumnoSeleccionadoId,
              decoration: const InputDecoration(labelText: 'Alumno'),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('-- Ninguno --'),
                ),
                ..._alumnosDelGrupo.map((a) {
                  final idStr = (a['id'] ?? a['id_alumno'])?.toString();
                  final label = '${a['nombres'] ?? a['nombre'] ?? ''} ${a['apellido_paterno'] ?? ''} ${a['apellido_materno'] ?? ''}'.trim();
                  return DropdownMenuItem<String?>(
                    value: idStr,
                    child: Text(label.isEmpty ? (a['matricula']?.toString() ?? 'Alumno') : label),
                  );
                }).toList(),
              ],
              onChanged: (String? v) => setState(() => _alumnoSeleccionadoId = v),
              isExpanded: true,
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Selecciona un grupo para ver sus alumnos. La búsqueda por nombre/apellidos fue deshabilitada.'),
            ),
          ],
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (para enviar Excel)')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Buscar'),
                  onPressed: _loading ? null : () => _buscar(enviarEmail: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Enviar por correo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_emailCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un email de destino')));
                            return;
                          }
                          _buscar(enviarEmail: true);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Expanded(
            child: _resultados.isEmpty
                ? const Center(child: Text('No hay resultados'))
                : ListView.separated(
                    itemCount: _resultados.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) => _buildItem(_resultados[i]),
                  ),
          ),
        ],
      ),
    );
  }
}