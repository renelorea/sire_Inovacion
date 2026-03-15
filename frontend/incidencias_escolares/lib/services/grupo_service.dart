import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/grupo.dart';
import '../utils/auth_utils.dart';

class GrupoService {
  Future<List<Grupo>> obtenerGrupos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/grupos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerGrupos - status: ${response.statusCode}', name: 'GrupoService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Grupo.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearGrupo(Grupo grupo) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/grupos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(grupo.toJson()),
    );

    developer.log('crearGrupo - status: ${resp.statusCode} - body: ${resp.body}', name: 'GrupoService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> editarGrupo(Grupo grupo) async {
    final payload = grupo.toJson();
    developer.log('editarGrupo - payload: ${jsonEncode(payload)}', name: 'GrupoService');
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/grupos/${grupo.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    developer.log('editarGrupo - status: ${resp.statusCode} - body: ${resp.body}', name: 'GrupoService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> eliminarGrupo(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/grupos/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarGrupo - status: ${resp.statusCode} - body: ${resp.body}', name: 'GrupoService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
