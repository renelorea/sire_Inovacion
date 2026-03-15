class SeguimientoEvidencia {
  final int id;
  final int idReporte;
  final String responsable;
  final String descripcion;
  final String fechaSeguimiento;
  final String estado;
  final String? evidenciaNombre;
  final String? evidenciaTipo;
  final int? evidenciaTamano;
  final String? evidenciaArchivo; // Base64 o URL
  final DateTime fechaCreacion;

  SeguimientoEvidencia({
    required this.id,
    required this.idReporte,
    required this.responsable,
    required this.descripcion,
    required this.fechaSeguimiento,
    required this.estado,
    this.evidenciaNombre,
    this.evidenciaTipo,
    this.evidenciaTamano,
    this.evidenciaArchivo,
    required this.fechaCreacion,
  });

  factory SeguimientoEvidencia.fromJson(Map<String, dynamic> json) {
    return SeguimientoEvidencia(
      id: json['id'] ?? 0,
      idReporte: json['id_reporte'] ?? json['idReporte'] ?? 0,
      responsable: json['responsable'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaSeguimiento: json['fecha_seguimiento'] ?? json['fechaSeguimiento'] ?? '',
      estado: json['estado'] ?? '',
      evidenciaNombre: json['evidencia_nombre'] ?? json['evidenciaNombre'],
      evidenciaTipo: json['evidencia_tipo'] ?? json['evidenciaTipo'],
      evidenciaTamano: json['evidencia_tamano'] ?? json['evidenciaTamano'],
      evidenciaArchivo: json['evidencia_archivo'] ?? json['evidenciaArchivo'],
      fechaCreacion: DateTime.tryParse(json['fecha_creacion'] ?? json['fechaCreacion'] ?? '') ?? DateTime.now(),
    );
  }

  bool get tieneEvidencia => evidenciaNombre != null && evidenciaNombre!.isNotEmpty;

  String get tamanoFormateado {
    if (evidenciaTamano == null || evidenciaTamano == 0) return '0 B';
    
    const sufijos = ['B', 'KB', 'MB', 'GB'];
    int indice = 0;
    double tamano = evidenciaTamano!.toDouble();
    
    while (tamano >= 1024 && indice < sufijos.length - 1) {
      tamano /= 1024;
      indice++;
    }
    
    return '${tamano.toStringAsFixed(2)} ${sufijos[indice]}';
  }

  bool get esImagen => evidenciaTipo?.startsWith('image/') ?? false;
  bool get esPDF => evidenciaTipo?.contains('pdf') ?? false;
}