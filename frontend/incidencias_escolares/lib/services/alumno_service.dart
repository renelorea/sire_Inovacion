import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/alumno.dart';
import '../utils/auth_utils.dart';

class AlumnoService {
  Future<List<Alumno>> obtenerAlumnos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/alumnos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerAlumnos - status: ${response.statusCode}', name: 'AlumnoService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Alumno.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearAlumno(Alumno a) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/alumnos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(a.toJson()),
    );

    developer.log('crearAlumno - status: ${resp.statusCode} - body: ${resp.body}', name: 'AlumnoService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> editarAlumno(Alumno a) async {
    final payload = a.toJson();
    developer.log('editarAlumno - payload: ${jsonEncode(payload)}', name: 'AlumnoService');
    try {
      final resp = await http.put(
        Uri.parse('$apiBaseUrl/alumnos/${a.id}'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      developer.log('editarAlumno - status: ${resp.statusCode} - body: ${resp.body}', name: 'AlumnoService');

      if (resp.statusCode == 200) {
        return;
      } else if (resp.statusCode == 401) {
        throw UnauthorizedException('Token inválido o expirado');
      } else {
        throw Exception('Error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e, st) {
      developer.log('editarAlumno - exception: $e', name: 'AlumnoService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> eliminarAlumno(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/alumnos/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarAlumno - status: ${resp.statusCode} - body: ${resp.body}', name: 'AlumnoService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
