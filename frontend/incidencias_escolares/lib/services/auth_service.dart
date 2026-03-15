import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_response.dart';
import '../utils/auth_utils.dart';

class AuthService {
  Future<LoginResponse?> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'correo': correo, 'contraseña': contrasena}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LoginResponse.fromJson(json);
    } else if (response.statusCode == 401) {
      // credenciales inválidas o respuesta de no autorizado
      throw UnauthorizedException('No autorizado: correo o contraseña incorrectos');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<bool> cambiarPassword(String correo, String passwordActual, String passwordNueva) async {
    final response = await http.put(
      Uri.parse('$apiBaseUrl/usuarios/cambiar-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'password_actual': passwordActual,
        'password_nueva': passwordNueva,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Contraseña actual incorrecta');
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
