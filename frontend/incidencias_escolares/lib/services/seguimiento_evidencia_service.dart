import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/seguimiento_evidencia.dart';
import '../utils/auth_utils.dart';

class SeguimientoEvidenciaService {
  
  Future<List<SeguimientoEvidencia>> obtenerSeguimientosPorReporte(int idReporte) async {
    final url = Uri.parse('$apiBaseUrl/reportes/$idReporte/seguimientos');
    
    developer.log('Obteniendo seguimientos para reporte: $idReporte', name: 'SeguimientoEvidenciaService');
    
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    developer.log('obtenerSeguimientos - status: ${resp.statusCode}', name: 'SeguimientoEvidenciaService');

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((json) => SeguimientoEvidencia.fromJson(json)).toList();
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<List<SeguimientoEvidencia>> obtenerTodosSeguimientos() async {
    final url = Uri.parse('$apiBaseUrl/seguimientos');
    
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((json) => SeguimientoEvidencia.fromJson(json)).toList();
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<String?> descargarEvidencia(int idSeguimiento) async {
    // 🔧 CORRECCIÓN: Usar el endpoint de preview que devuelve JSON con base64
    final url = Uri.parse('$apiBaseUrl/seguimientos/$idSeguimiento/evidencia/preview');
    
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['archivo']; // Base64 del archivo
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}