import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/usuario.dart';
import '../utils/auth_utils.dart';

class UsuarioService {
  Future<List<Usuario>> obtenerUsuarios() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/usuarios'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerUsuarios - status: ${response.statusCode}', name: 'UsuarioService');
    developer.log('obtenerUsuarios - body: ${response.body}', name: 'UsuarioService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearUsuario(Usuario usuario) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/usuarios'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(usuario.toJson()),
    );

    developer.log('crearUsuario - status: ${resp.statusCode} - body: ${resp.body}', name: 'UsuarioService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> editUsuario(Usuario usuario) async {
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/usuarios/${usuario.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(usuario.toJson()),
    );

    developer.log('editUsuario - status: ${resp.statusCode} - body: ${resp.body}', name: 'UsuarioService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> resetearContrasena(int id) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/usuarios/$id/reset-password'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    developer.log('resetearContrasena - status: ${resp.statusCode} - body: ${resp.body}', name: 'UsuarioService');

    if (resp.statusCode == 200) {
      // Retorna la respuesta que incluye msg, nueva_contrasena y usuario
      return jsonDecode(resp.body);
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else if (resp.statusCode == 404) {
      throw Exception('Usuario no encontrado o inactivo');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> cambiarContrasena(int id, String nuevaContrasena) async {
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/usuarios/$id/change-password'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nueva_contrasena': nuevaContrasena}),
    );

    developer.log('cambiarContrasena - status: ${resp.statusCode} - body: ${resp.body}', name: 'UsuarioService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else if (resp.statusCode == 400) {
      final errorData = jsonDecode(resp.body);
      throw Exception(errorData['msg'] ?? 'Datos inválidos');
    } else if (resp.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> eliminarUsuario(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/usuarios/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarUsuario - status: ${resp.statusCode} - body: ${resp.body}', name: 'UsuarioService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
