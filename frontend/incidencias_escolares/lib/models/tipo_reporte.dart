class TipoReporte {
  final int id;
  final String nombre;
  final String descripcion;
  final String gravedad;

  TipoReporte({required this.id, required this.nombre, required this.descripcion, required this.gravedad});

  factory TipoReporte.fromJson(Map<String, dynamic> json) => TipoReporte(
    id: json['id_tipo_reporte'] ?? 0,
    nombre: json['nombre'] ?? '',
    descripcion: json['descripcion'] ?? '',
    gravedad: json['gravedad'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id_tipo_reporte': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'gravedad': gravedad,
  };
}
