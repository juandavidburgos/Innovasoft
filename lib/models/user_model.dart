// user_model.dart
/// Modelo de datos para representar un usuario del sistema.
/// El campo [rol] puede ser 'Administrador' o 'Monitor' (Monitor = Entrenador).
class UserModel {
  final int? idUsuario;
  final String nombre;
  final String email;
  final String contrasena;
  final String rol; // 'Monitor' equivale a 'Entrenador'

  UserModel({
    this.idUsuario,
    required this.nombre,
    required this.email,
    required this.contrasena,
    required this.rol,
  });

  /// Convierte un Map (por ejemplo desde SQLite) a un objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        idUsuario: map['id_usuario'],
        nombre: map['nombre'],
        email: map['email'],
        contrasena: map['contrasena'],
        rol: map['rol'],
      );

  /// Convierte el objeto a un Map (por ejemplo para SQLite)
  Map<String, dynamic> toMap() => {
        if (idUsuario != null) 'id_usuario': idUsuario,
        'nombre': nombre,
        'email': email,
        'rol': rol,
      };

  /// Convierte un JSON a un objeto UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        idUsuario: json['id_usuario'],
        nombre: json['nombre'],
        email: json['email'],
        contrasena: json['contrasena'],
        rol: json['rol'],
      );

  /// Convierte un UserModel a JSON (por ejemplo para API)
  Map<String, dynamic> toJson() => {
        if (idUsuario != null) 'id_usuario': idUsuario,
        'nombre': nombre,
        'email': email,
        'contrasena':contrasena,
        'rol': rol,
      };
}
