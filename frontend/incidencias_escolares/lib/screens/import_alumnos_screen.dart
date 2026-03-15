import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import '../config/api_config.dart';
import '../config/global.dart';

class ImportAlumnosScreen extends StatefulWidget {
  @override
  _ImportAlumnosScreenState createState() => _ImportAlumnosScreenState();
}

class _ImportAlumnosScreenState extends State<ImportAlumnosScreen> {
  bool _loading = false;
  String? _result;

  Future<void> _pickAndUpload() async {
    setState(() { _result = null; });
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true, // permite bytes en web y móviles
    );
    if (res == null) return;

    final file = res.files.single;
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$apiBaseUrl/alumnos/import');
      final request = http.MultipartRequest('POST', uri);
      if (jwtToken != null) request.headers['Authorization'] = 'Bearer $jwtToken';

      // preferir path si existe (Android), sino bytes
      if (file.path != null && file.path!.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path!,
            contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet')));
      } else if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name,
            contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet')));
      } else {
        throw Exception('No se pudo leer archivo');
      }

      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      if (streamed.statusCode == 201 || streamed.statusCode == 200) {
        setState(() => _result = 'Importación exitosa: $respStr');
      } else {
        setState(() => _result = 'Error import: ${streamed.statusCode} -> $respStr');
      }
    } catch (e) {
      setState(() => _result = 'Excepción: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Importar alumnos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Selecciona un archivo Excel (.xlsx / .xls) con columnas: nombre, apaterno, amaterno, matricula, grupo_id, correo'),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text('Seleccionar y subir Excel'),
              onPressed: _loading ? null : _pickAndUpload,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 12),
            if (_loading) CircularProgressIndicator(),
            if (_result != null) ...[
              SizedBox(height: 12),
              SelectableText(_result!),
            ],
          ],
        ),
      ),
    );
  }
}