import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/seguimiento.dart';
import '../utils/auth_utils.dart';

class SeguimientoService {
  Future<List<Seguimiento>> obtenerSeguimientos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerSeguimientos - status: ${response.statusCode}', name: 'SeguimientoService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Seguimiento.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Seguimiento> obtenerSeguimientoPorId(int id) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerSeguimientoPorId($id) - status: ${response.statusCode}', name: 'SeguimientoService');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Seguimiento.fromJson(data);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Seguimiento no encontrado: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> crearSeguimiento(Seguimiento seguimiento) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );

    developer.log('crearSeguimiento - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error al crear seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> editarSeguimiento(Seguimiento seguimiento) async {
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/seguimientos/${seguimiento.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );

    developer.log('editarSeguimiento(${seguimiento.id}) - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error al editar seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> eliminarSeguimiento(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarSeguimiento($id) - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error al eliminar seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }
}
