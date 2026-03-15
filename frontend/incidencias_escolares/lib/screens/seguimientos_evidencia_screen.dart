import 'package:flutter/material.dart';
import '../models/seguimiento_evidencia.dart';
import '../models/reporte.dart';
import '../services/seguimiento_evidencia_service.dart';
import 'seguimiento_detalle_screen.dart';

class SeguimientosEvidenciaScreen extends StatefulWidget {
  final Reporte? reporte; // Si viene de un reporte específico
  final int? idReporte;   // 🔧 NUEVO: O solo el ID del reporte
  
  const SeguimientosEvidenciaScreen({
    Key? key, 
    this.reporte,
    this.idReporte,  // 🔧 NUEVO parámetro
  }) : super(key: key);

  @override
  State<SeguimientosEvidenciaScreen> createState() => _SeguimientosEvidenciaScreenState();
}

class _SeguimientosEvidenciaScreenState extends State<SeguimientosEvidenciaScreen> {
  final SeguimientoEvidenciaService _service = SeguimientoEvidenciaService();
  
  late Future<List<SeguimientoEvidencia>> _seguimientos;
  bool _soloConEvidencia = false;

  @override
  void initState() {
    super.initState();
    _cargarSeguimientos();
  }

  void _cargarSeguimientos() {
    // 🔧 MODIFICADO: Usar el reporte o el ID del reporte
    final reporteId = widget.reporte?.id ?? widget.idReporte;
    
    if (reporteId != null) {
      // Cargar solo seguimientos de este reporte
      _seguimientos = _service.obtenerSeguimientosPorReporte(reporteId);
    } else {
      // Cargar todos los seguimientos
      _seguimientos = _service.obtenerTodosSeguimientos();
    }
  }

  void _filtrarSeguimientos() {
    _cargarSeguimientos();
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 MODIFICADO: Título dinámico
    final titulo = widget.reporte != null 
        ? 'Seguimientos - Folio ${widget.reporte!.folio}'
        : widget.idReporte != null
          ? 'Seguimientos - Reporte #${widget.idReporte}'
          : 'Seguimientos con Evidencias';

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
        title: Text(titulo, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _cargarSeguimientos();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Text('Filtros:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    Text('Solo con evidencia'),
                    Switch(
                      value: _soloConEvidencia,
                      onChanged: (value) {
                        setState(() {
                          _soloConEvidencia = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de seguimientos
          Expanded(
            child: FutureBuilder<List<SeguimientoEvidencia>>(
              future: _seguimientos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error al cargar seguimientos'),
                        SizedBox(height: 8),
                        Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cargarSeguimientos();
                            });
                          },
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay seguimientos registrados'),
                      ],
                    ),
                  );
                }

                List<SeguimientoEvidencia> seguimientos = snapshot.data!;
                
                // Aplicar filtro de evidencia
                if (_soloConEvidencia) {
                  seguimientos = seguimientos.where((s) => s.tieneEvidencia).toList();
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: seguimientos.length,
                  itemBuilder: (context, index) {
                    final seguimiento = seguimientos[index];
                    return _buildSeguimientoCard(seguimiento);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeguimientoCard(SeguimientoEvidencia seguimiento) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeguimientoDetalleScreen(seguimiento: seguimiento),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(seguimiento.estado),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      seguimiento.estado,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    seguimiento.fechaSeguimiento,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Responsable
              Text(
                'Responsable: ${seguimiento.responsable}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Descripción
              Text(
                seguimiento.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              
              SizedBox(height: 12),
              
              // Footer con evidencia e info del reporte
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info del reporte
                  Text(
                    'Reporte #${seguimiento.idReporte}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  // Evidencia
                  if (seguimiento.tieneEvidencia) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          seguimiento.esImagen ? Icons.image : 
                          seguimiento.esPDF ? Icons.picture_as_pdf : Icons.attach_file,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          seguimiento.tamanoFormateado,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Sin evidencia',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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