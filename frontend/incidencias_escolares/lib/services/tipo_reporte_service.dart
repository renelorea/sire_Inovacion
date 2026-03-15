import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/tipo_reporte.dart';
import '../utils/auth_utils.dart';

class TipoReporteService {
  Future<List<TipoReporte>> obtenerTipos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/tipos-reporte'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerTipos - status: ${response.statusCode}', name: 'TipoReporteService');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TipoReporte.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> crearTipo(TipoReporte tipo) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/tipos-reporte'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(tipo.toJson()),
    );

    developer.log('crearTipo - status: ${resp.statusCode} - body: ${resp.body}', name: 'TipoReporteService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> editarTipo(TipoReporte tipo) async {
    final payload = tipo.toJson();
    developer.log('editarTipo - payload: ${jsonEncode(payload)}', name: 'TipoReporteService');

    final resp = await http.put(
      Uri.parse('$apiBaseUrl/tipos-reporte/${tipo.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    developer.log('editarTipo - status: ${resp.statusCode} - body: ${resp.body}', name: 'TipoReporteService');

    if (resp.statusCode == 200) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> eliminarTipo(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/tipos-reporte/$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('eliminarTipo - status: ${resp.statusCode} - body: ${resp.body}', name: 'TipoReporteService');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
