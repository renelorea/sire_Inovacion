import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reporte.dart';
import '../models/seguimiento.dart';
import '../services/reporte_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../config/global.dart'; // Para acceder al usuario loggeado
import 'seguimientos_evidencia_screen.dart'; // 🔧 AGREGAR ESTE IMPORT

// Clase para manejar imágenes de evidencia
class ImagenEvidencia {
  final String nombre;
  final String tipo;
  final Uint8List bytes;
  final String base64;
  
  ImagenEvidencia({
    required this.nombre,
    required this.tipo,
    required this.bytes,
  }) : base64 = base64Encode(bytes);
}

class ReporteDetailScreen extends StatefulWidget {
  final Reporte reporte;

  ReporteDetailScreen({required this.reporte});

  @override
  _ReporteDetailScreenState createState() => _ReporteDetailScreenState();
}

class _ReporteDetailScreenState extends State<ReporteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _responsableCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  ImagenEvidencia? _imagenSeleccionada;
  
  DateTime _fechaSeguimiento = DateTime.now();
  String _estadoSeguimiento = 'Abierto';
  String? _nuevoEstatusReporte;
  bool _guardando = false;

  final List<String> _estatusReporteOpciones = ['Abierto', 'En Seguimiento', 'Cerrado'];
  final List<String> _estadoSeguimientoOpciones = ['Abierto', 'En Progreso', 'Completado'];

  final ReporteService _service = ReporteService();
  List<Seguimiento> _seguimientos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Establecer el usuario loggeado como responsable por defecto
    _responsableCtrl.text = usuarioNombreCompleto ?? 'Usuario no identificado';
    _cargarSeguimientos();
  }

  Future<void> _cargarSeguimientos() async {
    try {
      final seguimientos = await _service.obtenerSeguimientosByReporte(widget.reporte.id);
      setState(() {
        _seguimientos = seguimientos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar seguimientos: $e')),
      );
    }
  }

  // Método para seleccionar imagen
  void _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _tomarFoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarDeGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _tomarFoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    _procesarImagen(image);
  }

  void _seleccionarDeGaleria() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    _procesarImagen(image);
  }

  void _procesarImagen(XFile? image) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      
      // Validar tamaño (máximo 5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La imagen es muy grande. Máximo 5MB permitido.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _imagenSeleccionada = ImagenEvidencia(
          nombre: image.name,
          tipo: 'image/jpeg',
          bytes: bytes,
        );
      });
    }
  }

  // Widget para el selector de imágenes
  Widget _buildSelectorImagen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imagen de evidencia (opcional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              _imagenSeleccionada != null ? Icons.image : Icons.add_a_photo,
              color: _imagenSeleccionada != null ? Colors.green : Colors.grey,
            ),
            title: Text(
              _imagenSeleccionada?.nombre ?? 'Seleccionar imagen de evidencia',
              style: TextStyle(
                color: _imagenSeleccionada != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
            subtitle: _imagenSeleccionada != null 
                ? Text(
                    'Tamano: ${(_imagenSeleccionada!.bytes.length / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : Text('JPG, PNG (máx. 5MB)'),
            trailing: _imagenSeleccionada != null 
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.red),
                    onPressed: () => setState(() => _imagenSeleccionada = null),
                  )
                : Icon(Icons.camera_alt, color: Colors.grey),
            onTap: _seleccionarImagen,
          ),
        ),
        if (_imagenSeleccionada != null) ...[
          SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _imagenSeleccionada!.bytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Agregar métodos faltantes
  String _getFolio() {
    return widget.reporte.folio ?? 'Sin folio';
  }

  String _getEstatus() {
    return widget.reporte.estatus ?? 'Sin estatus';
  }

  String _getDescripcion() {
    return widget.reporte.descripcionHechos ?? 'Sin descripción';
  }

  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeguimiento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeguimiento = fecha;
      });
    }
  }

  Future<void> _guardarSeguimiento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      // Crear el mapa de datos del seguimiento
      final Map<String, dynamic> seguimientoData = {
        'id_reporte': widget.reporte.id,
        'responsable': _responsableCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'fecha_seguimiento': DateFormat('yyyy-MM-dd').format(_fechaSeguimiento),
        'estado': _estadoSeguimiento,
      };

      // Agregar imagen si existe
      if (_imagenSeleccionada != null) {
        seguimientoData.addAll({
          'evidencia_archivo': _imagenSeleccionada!.base64,
          'evidencia_nombre': _imagenSeleccionada!.nombre,
          'evidencia_tipo': _imagenSeleccionada!.tipo,
          'evidencia_tamano': _imagenSeleccionada!.bytes.length,
        });
      }

      final exito = await _service.crearSeguimientoConArchivo(seguimientoData, nuevoEstatusReporte: _nuevoEstatusReporte);

      if (exito) {
        // Mostrar diálogo de confirmación y regresar
        await showDialog<void>(
          context: context,
          barrierDismissible: false, // No se puede cerrar tocando fuera
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('¡Éxito!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('El seguimiento se guardó correctamente.'),
                  if (_nuevoEstatusReporte != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'El estatus del reporte se cambió a: $_nuevoEstatusReporte',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                  if (_imagenSeleccionada != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Imagen de evidencia adjuntada: ${_imagenSeleccionada!.nombre}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar diálogo
                    Navigator.of(context).pop(true); // Regresar a pantalla anterior con resultado
                  },
                  child: Text('Continuar'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Mostrar error si no se pudo guardar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar el seguimiento. Intente nuevamente.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Mostrar diálogo de error
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ocurrió un error al guardar el seguimiento:'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '$e',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Entendido'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Detalle - Folio: ${_getFolio()}', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del reporte
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información del Reporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Estatus actual: ${_getEstatus()}'),
                      SizedBox(height: 4),
                      Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_getDescripcion(), style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Formulario de seguimiento
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agregar Seguimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _responsableCtrl,
                        readOnly: true, // Campo de solo lectura
                        decoration: InputDecoration(
                          labelText: 'Responsable *',
                          hintText: 'Usuario loggeado',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: Icon(Icons.person, color: Colors.green),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Error: Usuario no identificado' : null,
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descripcionCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Campo obligatorio',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa descripción' : null,
                      ),
                      SizedBox(height: 16),
                      
                      _buildSelectorImagen(),
                      SizedBox(height: 16),
                      
                      // Fecha de seguimiento
                      Row(
                        children: [
                          Expanded(
                            child: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeguimiento)}'),
                          ),
                          TextButton(
                            onPressed: _seleccionarFecha,
                            child: Text('Seleccionar fecha'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Estado del seguimiento
                      DropdownButtonFormField<String>(
                        value: _estadoSeguimiento,
                        items: _estadoSeguimientoOpciones.map((estado) {
                          return DropdownMenuItem(value: estado, child: Text(estado));
                        }).toList(),
                        onChanged: (value) => setState(() => _estadoSeguimiento = value!),
                        decoration: InputDecoration(labelText: 'Estado del seguimiento'),
                      ),
                      SizedBox(height: 16),
                      
                      // Cambiar estatus del reporte (opcional)
                      DropdownButtonFormField<String>(
                        value: _nuevoEstatusReporte?.isNotEmpty == true ? _nuevoEstatusReporte : null,
                        items: [
                          DropdownMenuItem(value: null, child: Text('No cambiar estatus')),
                          ..._estatusReporteOpciones.map((estatus) {
                            return DropdownMenuItem(value: estatus, child: Text(estatus));
                          }).toList(),
                        ],
                        onChanged: (value) => setState(() => _nuevoEstatusReporte = value),
                        decoration: InputDecoration(labelText: 'Cambiar estatus del reporte (opcional)'),
                      ),
                      SizedBox(height: 20),
                      
                      // Botones guardar y cancelar
                      Row(
                        children: [
                          // Botón Cancelar
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _guardando ? null : () {
                                // Mostrar confirmación si hay datos en el formulario
                                if (_responsableCtrl.text.isNotEmpty || _descripcionCtrl.text.isNotEmpty || _imagenSeleccionada != null) {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('¿Cancelar?'),
                                      content: Text('Se perderán los datos ingresados. ¿Está seguro?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                            Navigator.of(context).pop(); // Regresar sin guardar
                                          },
                                          child: Text('Sí, cancelar'),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pop(); // Regresar directamente si no hay datos
                                }
                              },
                              icon: Icon(Icons.cancel),
                              label: Text('Cancelar'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Botón Guardar
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _guardando ? null : _guardarSeguimiento,
                              icon: _guardando ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.save),
                              label: Text(_guardando ? 'Guardando...' : 'Guardar seguimiento'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Gestión de Seguimientos
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Seguimientos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.timeline),
                              label: Text('Ver Seguimientos'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeguimientosEvidenciaScreen(
                                      reporte: widget.reporte,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.refresh),
                              label: Text('Actualizar'),
                              onPressed: () async {
                                await _cargarSeguimientos();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Seguimientos actualizados')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Lista de seguimientos existentes
              if (_seguimientos.isNotEmpty) ...[
                Text('Seguimientos Existentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ..._seguimientos.map((seg) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Responsable: ${seg.responsable}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Fecha: ${seg.fechaSeguimiento}'),
                        SizedBox(height: 4),
                        Text('Descripción: ${seg.descripcion}'),
                        if (seg.evidenciaNombre != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image, color: Colors.blue, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    seg.evidenciaNombre!,
                                    style: TextStyle(color: Colors.blue.shade700),
                                  ),
                                ),
                                if (seg.evidenciaTamano != null)
                                  Text(
                                    '${(seg.evidenciaTamano! / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 4),
                        Text('Estado: ${seg.estado}', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}