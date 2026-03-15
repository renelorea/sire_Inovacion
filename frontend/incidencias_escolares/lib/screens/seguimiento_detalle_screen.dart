import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/seguimiento_evidencia.dart';
import '../models/reporte.dart';        // 🔧 AGREGAR
import '../models/alumno.dart';         // 🔧 AGREGAR
import '../models/tipo_reporte.dart';   // 🔧 AGREGAR
import '../models/usuario.dart';        // 🔧 AGREGAR
import '../services/seguimiento_evidencia_service.dart';
import 'seguimientos_evidencia_screen.dart';

class SeguimientoDetalleScreen extends StatefulWidget {
  final SeguimientoEvidencia seguimiento;
  
  const SeguimientoDetalleScreen({Key? key, required this.seguimiento}) : super(key: key);

  @override
  State<SeguimientoDetalleScreen> createState() => _SeguimientoDetalleScreenState();
}

class _SeguimientoDetalleScreenState extends State<SeguimientoDetalleScreen> {
  final SeguimientoEvidenciaService _service = SeguimientoEvidenciaService();
  
  bool _cargandoEvidencia = false;
  Uint8List? _evidenciaBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Seguimiento #${widget.seguimiento.id}', style: TextStyle(color: Colors.white)),
        actions: [
          if (widget.seguimiento.tieneEvidencia)
            IconButton(
              icon: Icon(Icons.visibility),
              onPressed: _cargarEvidencia,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de información básica
            _buildInfoCard(),
            
            SizedBox(height: 16),
            
            // Card de evidencia (si existe)
            if (widget.seguimiento.tieneEvidencia) ...[
              _buildEvidenciaCard(),
              SizedBox(height: 16),
            ],
            
            // Botones de acción
            _buildBotonesAccion(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información del Seguimiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(widget.seguimiento.estado),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.seguimiento.estado,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Información detallada
            _buildInfoRow('ID Reporte:', '#${widget.seguimiento.idReporte}'),
            _buildInfoRow('Responsable:', widget.seguimiento.responsable),
            _buildInfoRow('Fecha Seguimiento:', widget.seguimiento.fechaSeguimiento),
            _buildInfoRow('Fecha Creación:', _formatDateTime(widget.seguimiento.fechaCreacion)),
            
            SizedBox(height: 16),
            
            // Descripción
            Text(
              'Descripción:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                widget.seguimiento.descripcion,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenciaCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Evidencia Adjunta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            _buildInfoRow('Nombre:', widget.seguimiento.evidenciaNombre ?? 'N/A'),
            _buildInfoRow('Tipo:', widget.seguimiento.evidenciaTipo ?? 'N/A'),
            _buildInfoRow('Tamaño:', widget.seguimiento.tamanoFormateado),
            
            SizedBox(height: 16),
            
            // Preview de evidencia
            if (_evidenciaBytes != null) ...[
              if (widget.seguimiento.esImagen) ...[
                Text('Vista previa:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _evidenciaBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        widget.seguimiento.esPDF ? Icons.picture_as_pdf : Icons.description,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 8),
                      Text('Archivo descargado correctamente'),
                    ],
                  ),
                ),
              ],
            ] else ...[
              ElevatedButton.icon(
                icon: _cargandoEvidencia ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) : Icon(Icons.visibility),
                label: Text(_cargandoEvidencia ? 'Cargando...' : 'Ver Evidencia'),
                onPressed: _cargandoEvidencia ? null : _cargarEvidencia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.copy),
                    label: Text('Copiar Info'),
                    onPressed: _copiarInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                if (widget.seguimiento.tieneEvidencia) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.download),
                      label: Text('Descargar'),
                      onPressed: _cargarEvidencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.timeline),
              label: Text('Ver Otros Seguimientos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeguimientosEvidenciaScreen(
                      idReporte: widget.seguimiento.idReporte,  // 🔧 Usar solo el ID
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarEvidencia() async {
    if (_cargandoEvidencia) return;
    
    setState(() {
      _cargandoEvidencia = true;
    });

    try {
      final base64Data = await _service.descargarEvidencia(widget.seguimiento.id);
      if (base64Data != null) {
        setState(() {
          _evidenciaBytes = base64Decode(base64Data);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar evidencia: $e')),
      );
    } finally {
      setState(() {
        _cargandoEvidencia = false;
      });
    }
  }

  Future<void> _copiarInfo() async {
    final info = '''
Seguimiento #${widget.seguimiento.id}
Reporte: #${widget.seguimiento.idReporte}
Responsable: ${widget.seguimiento.responsable}
Estado: ${widget.seguimiento.estado}
Fecha: ${widget.seguimiento.fechaSeguimiento}
Descripción: ${widget.seguimiento.descripcion}
${widget.seguimiento.tieneEvidencia ? 'Evidencia: ${widget.seguimiento.evidenciaNombre} (${widget.seguimiento.tamanoFormateado})' : 'Sin evidencia adjunta'}
''';

    await Clipboard.setData(ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Información copiada al portapapeles')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'abierto':
        return Colors.blue;
      case 'en proceso':
      case 'en seguimiento':
        return Colors.orange;
      case 'cerrado':
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}