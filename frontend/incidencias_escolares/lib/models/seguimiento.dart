class Seguimiento {
  final int idReporte;
  final String responsable;
  final String fechaSeguimiento;
  final String descripcion;
  final String? evidenciaNombre;    
  final String? evidenciaTipo;      
  final int? evidenciaTamano;       // Cambio: tamaño en bytes
  final String estado;
  final int validado;

  Seguimiento({
    required this.idReporte,
    required this.responsable,
    required this.fechaSeguimiento,
    required this.descripcion,
    this.evidenciaNombre,
    this.evidenciaTipo,
    this.evidenciaTamano,
    required this.estado,
    required this.validado,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      idReporte: json['id_reporte'],
      responsable: json['responsable'],
      fechaSeguimiento: json['fecha_seguimiento'],
      descripcion: json['descripcion'],
      evidenciaNombre: json['evidencia_nombre'],
      evidenciaTipo: json['evidencia_tipo'],
      evidenciaTamano: json['evidencia_tamano'],
      estado: json['estado'],
      validado: json['validado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reporte': idReporte,
      'responsable': responsable,
      'fecha_seguimiento': fechaSeguimiento,
      'descripcion': descripcion,
      'evidencia_nombre': evidenciaNombre,
      'evidencia_tipo': evidenciaTipo,
      'evidencia_tamano': evidenciaTamano,
      'estado': estado,
      'validado': validado,
    };
  }
}
