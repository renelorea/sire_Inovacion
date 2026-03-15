class Usuario {
  final int id;
  final String nombre;
  final String apaterno;
  final String amaterno;
  final String correo;
  final String contrasena;
  final String rol;

  Usuario({required this.id, required this.nombre, required this.apaterno, required this.amaterno, required this.correo, required this.contrasena, required this.rol});

  

  factory Usuario.fromJson(Map<String, dynamic> json) {
    print(json);
    if (json['rol'] == null) {
      throw Exception('Faltan campos en la respuesta del login');
    }

    return Usuario(
    id: json['id_usuario'] ?? 0,
    nombre: json['nombres'] ?? '',
    apaterno: json['apellido_paterno'] ?? '',
    amaterno: json['apellido_materno'] ?? '',
    correo: json['email'] ?? '',
    contrasena: json['contrasena'] ?? '',
    rol: json['rol'] ?? '',
  );
  }

  Map<String, dynamic> toJson() => {
    'nombres': nombre,
    'apellido_paterno': apaterno,
    'apellido_materno': amaterno,
    'email': correo,
    'contrasena': contrasena,
    'rol': rol,
  };
}

