import 'alumno.dart';
import 'usuario.dart';
import 'tipo_reporte.dart';

class Reporte {
  final int id;
  final String folio;
  final String descripcionHechos;
  final String? accionesTomadas;
  final String fechaIncidencia;
  final String fechaCreacion;
  final String estatus;

  final Alumno alumno;
  final Usuario usuario;
  final TipoReporte tipoReporte;

  Reporte({
    required this.id,
    required this.folio,
    required this.descripcionHechos,
    this.accionesTomadas,
    required this.fechaIncidencia,
    required this.fechaCreacion,
    required this.estatus,
    required this.alumno,
    required this.usuario,
    required this.tipoReporte,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
    id: json['id_reporte'] ?? 0,
    folio: json['folio'] ?? '',
    descripcionHechos: json['descripcion_hechos'] ?? '',
    accionesTomadas: json['acciones_tomadas'],
    fechaIncidencia: json['fecha_incidencia'] ?? '',
    fechaCreacion: json['fecha_creacion'] ?? '',
    estatus: json['estatus'] ?? 'Abierto',
    alumno: Alumno.fromJson(json['alumno']),
    usuario: Usuario.fromJson(json['usuario']),
    tipoReporte: TipoReporte.fromJson(json['tipo_reporte']),
  );

  Map<String, dynamic> toJson() => {
    'folio': folio,
    'descripcion_hechos': descripcionHechos,
    'acciones_tomadas': accionesTomadas,
    'fecha_incidencia': fechaIncidencia,
    'estatus': estatus,
    'id_alumno': alumno.id,
    'id_usuario_que_reporta': usuario.id,
    'id_tipo_reporte': tipoReporte.id,
  };
}
