import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/reporte.dart';
import '../models/seguimiento.dart';
import '../utils/auth_utils.dart';

class ReporteService {
  Future<List<Reporte>> obtenerReportes() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/reportes'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerReportes - status: ${response.statusCode}', name: 'ReporteService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // log opcional del contenido
      developer.log('obtenerReportes - items: ${data.length}', name: 'ReporteService');
      return data.map((e) => Reporte.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearReporte(Reporte reporte) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/reportes'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(reporte.toJson()),
    );

    developer.log('crearReporte - status: ${resp.statusCode} - body: ${resp.body}', name: 'ReporteService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> editarReporte(Reporte reporte) async {
    final payload = reporte.toJson();
    developer.log('editarReporte - payload: ${jsonEncode(payload)}', name: 'ReporteService');

    final resp = await http.put(
      Uri.parse('$apiBaseUrl/reportes/${reporte.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    developer.log('editarReporte - status: ${resp.statusCode} - body: ${resp.body}', name: 'ReporteService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> eliminarReporte(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/reportes/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarReporte - status: ${resp.statusCode} - body: ${resp.body}', name: 'ReporteService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<dynamic> consultar({
    String? grupo,
    String? alumno, // id del alumno seleccionado (como string)
    Map<String, String>? alumnoData, // datos adicionales del alumno (nombre, apellidos, matricula)
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? email,
  }) async {
    final params = <String, String>{};
    if (grupo != null && grupo.isNotEmpty) params['grupo'] = grupo;
    if (alumno != null && alumno.isNotEmpty) params['alumno'] = alumno; // <-- agregado
    // si se pasan datos completos del alumno, los agregamos como query params prefijados
    if (alumnoData != null) {
      alumnoData.forEach((k, v) {
        if (v.isNotEmpty) params['alumno_$k'] = v;
      });
    }
    if (nombre != null && nombre.isNotEmpty) params['nombre'] = nombre;
    if (apellidoPaterno != null && apellidoPaterno.isNotEmpty) params['apellido_paterno'] = apellidoPaterno;
    if (apellidoMaterno != null && apellidoMaterno.isNotEmpty) params['apellido_materno'] = apellidoMaterno;
    if (email != null && email.isNotEmpty) params['email'] = email;

    final uri = Uri.parse('$apiBaseUrl/reportes/reporte').replace(queryParameters: params.isEmpty ? null : params);

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jwtToken != null && jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }

    final resp = await http.get(uri, headers: headers);
    developer.log('consultar - ${uri.toString()} - status: ${resp.statusCode}', name: 'ReporteService');

    if (resp.statusCode == 200) {
      final decoded = json.decode(resp.body);
      return decoded;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<List<Seguimiento>> obtenerSeguimientosByReporte(int reporteId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/seguimientos/reporte/$reporteId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Seguimiento.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error obtenerSeguimientosByReporte: $e');
      return [];
    }
  }

  Future<bool> crearSeguimientoConArchivo(Map<String, dynamic> seguimientoData, {String? nuevoEstatusReporte}) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/seguimientos'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(seguimientoData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Si se especifica cambio de estatus del reporte
        if (nuevoEstatusReporte != null) {
          await actualizarEstatusReporte(seguimientoData['id_reporte'], nuevoEstatusReporte);
        }
        return true;
      }
      return false;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> actualizarEstatusReporte(int reporteId, String nuevoEstatus) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/reportes/$reporteId/estatus'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'estatus': nuevoEstatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizarEstatusReporte: $e');
      return false;
    }
  }
}
