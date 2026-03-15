import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart'; // <-- agregado para obtener jwtToken
import '../models/seguimiento.dart';
import '../utils/auth_utils.dart';

class SeguimientoService {
  // Tamaño máximo permitido: 2MB en bytes
  static const int MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB

  Future<bool> crearSeguimiento(Seguimiento s, {String? nuevoEstatusReporte}) async {
    // Validar tamaño del archivo antes de enviar
    if (!_validarTamanoArchivo(s)) {
      throw Exception('El archivo es muy grande. Tamaño máximo permitido: 2MB');
    }

    final url = Uri.parse('$apiBaseUrl/seguimientos');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(s.toJson()),
    );

    developer.log('crearSeguimiento - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Si se solicita, actualizar también el estatus del reporte
      if (nuevoEstatusReporte != null) {
        final actualizarOk = await _actualizarEstatusReporte(s.idReporte, nuevoEstatusReporte);
        return actualizarOk;
      }
      return true;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  /// Valida que el tamaño del archivo no exceda el límite permitido
  bool _validarTamanoArchivo(Seguimiento seguimiento) {
    // Si no hay archivo, no hay nada que validar
    if (seguimiento.evidenciaTamano == null || seguimiento.evidenciaTamano == 0) {
      return true;
    }

    // Verificar si el tamaño excede el límite
    if (seguimiento.evidenciaTamano! > MAX_FILE_SIZE) {
      final tamanoMB = (seguimiento.evidenciaTamano! / (1024 * 1024)).toStringAsFixed(2);
      developer.log('Archivo muy grande: ${tamanoMB}MB. Máximo permitido: 2MB', 
                   name: 'SeguimientoService');
      return false;
    }

    final tamanoMB = (seguimiento.evidenciaTamano! / (1024 * 1024)).toStringAsFixed(2);
    developer.log('Tamaño de archivo válido: ${tamanoMB}MB', name: 'SeguimientoService');
    return true;
  }

  /// Obtiene el tamaño del archivo en formato legible
  String obtenerTamanoFormateado(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    
    const sufijos = ['B', 'KB', 'MB', 'GB'];
    int indice = 0;
    double tamano = bytes.toDouble();
    
    while (tamano >= 1024 && indice < sufijos.length - 1) {
      tamano /= 1024;
      indice++;
    }
    
    return '${tamano.toStringAsFixed(2)} ${sufijos[indice]}';
  }

  Future<bool> _actualizarEstatusReporte(int idReporte, String estatus) async {
    final url = Uri.parse('$apiBaseUrl/reportes/$idReporte/estatus');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'estatus': estatus}),
    );

    developer.log('actualizarEstatusReporte - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 200) return true;
    else if (resp.statusCode == 401) throw UnauthorizedException('Token inválido o expirado');
    else throw Exception('Error ${resp.statusCode}: ${resp.body}');
  }
}