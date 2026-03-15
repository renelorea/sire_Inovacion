class Grupo {
  final int id;
  final String descripcion;
  final int grado;
  final String ciclo;
  final int idTutor;

  Grupo({
    required this.id,
    required this.descripcion,
    required this.grado,
    required this.ciclo,
    required this.idTutor,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) => Grupo(
    id: json['id_grupo'] ?? 0,
    descripcion: json['Descripcion'] ?? '',
    grado: json['grado'] ?? 0,
    ciclo: json['ciclo_escolar'] ?? '',
    idTutor: json['id_tutor'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id_grupo': id,
    'Descripcion': descripcion,
    'grado': grado,
    'ciclo_escolar': ciclo,
    'id_tutor': idTutor,
  };
}
