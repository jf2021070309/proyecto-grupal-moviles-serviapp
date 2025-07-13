class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String password;
  final String rol;
  final String dni;
  final String celular;
  final List<String>? tipoTrabajo;
  final List<String>? experiencia;
  final bool isOnline;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    required this.dni,
    required this.celular,
    this.tipoTrabajo,
    this.experiencia,
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
      'dni': dni,
      'celular': celular,
      'tipoTrabajo': tipoTrabajo,
      'experiencia': experiencia,
      'isOnline': isOnline,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      rol: map['rol'] ?? '',
      dni: map['dni'] ?? '',
      celular: map['celular'] ?? '',
      tipoTrabajo:
          (map['tipoTrabajo'] is List)
              ? List<String>.from(
                (map['tipoTrabajo'] as List).map((e) => e.toString()),
              )
              : null,
      experiencia:
          (map['experiencia'] is List)
              ? List<String>.from(
                (map['experiencia'] as List).map((e) => e.toString()),
              )
              : null,
      isOnline: map['isOnline'] ?? false,
    );
  }
}
