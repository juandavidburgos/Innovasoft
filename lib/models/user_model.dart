// user_model.dart
/// Modelo de datos para representar un usuario del sistema.
/// El campo [rol] puede ser 'Administrador' o 'Monitor' (Monitor = Entrenador).
class UserModel {
  final int? id_usuario;
  final String nombre;
  final String email;
  final String? contrasena;
  final String rol; // 'Monitor' equivale a 'Entrenador'
  final String estado;

  UserModel({
    this.id_usuario,
    required this.nombre,
    required this.email,
    this.contrasena,
    required this.rol,
    required this.estado,
  });

  /// Convierte un Map (por ejemplo desde SQLite) a un objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id_usuario: map['id_usuario'],
        nombre: map['nombre'],
        email: map['email'],
        contrasena: map['contrasena'],
        rol: map['rol'],
        estado: map['estado'],
      );

  /// Convierte el objeto a un Map (por ejemplo para SQLite)
  Map<String, dynamic> toMap() => {
        if (id_usuario != null) 'id_usuario': id_usuario,
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'estado':estado,
      };

  /// Convierte un JSON a un objeto UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id_usuario: json['id_usuario'],
        nombre: json['nombre'],
        email: json['email'],
        contrasena: json['contrasena'],
        rol: json['rol'],
        estado: json['estado']
      );

  /// Convierte un UserModel a JSON (por ejemplo para API)
  Map<String, dynamic> toJson() => {
        if (id_usuario != null) 'id_usuario': id_usuario,
        'nombre': nombre,
        'email': email,
        'contrasena':contrasena,
        'rol': rol,
        'estado':estado,
      };
}
