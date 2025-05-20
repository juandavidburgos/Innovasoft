// user_model.dart
/// Modelo de datos para representar un usuario del sistema.
/// El campo [rol] puede ser 'Administrador' o 'Monitor' (Monitor = Entrenador).
class UserModel {
  final int? id_usuario;
  final String nombre;
  final String email;
  final String? contrasena;
  final String rol; // 'Monitor' equivale a 'Entrenador'
  final String estado_monitor;
  bool sincronizado;

  UserModel({
    this.id_usuario,
    required this.nombre,
    required this.email,
    this.contrasena,
    required this.rol,
    required this.estado_monitor,
    this.sincronizado = false,
  });

  /// Convierte un Map (por ejemplo desde SQLite) a un objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id_usuario: map['id_usuario'],
        nombre: map['nombre'],
        email: map['email'],
        contrasena: map['contrasena'],
        rol: map['rol'],
        estado_monitor: map['estado_monitor'],
        sincronizado: map['sincronizado'] == 1,
      );

  /// Convierte el objeto a un Map (por ejemplo para SQLite)
  Map<String, dynamic> toMap() => {
        if (id_usuario != null) 'id_usuario': id_usuario,
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'estado_monitor':estado_monitor,
        'sincronizado': sincronizado ? 1 : 0,
      };

  /// Convierte un JSON a un objeto UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id_usuario: json['id_usuario'],
        nombre: json['nombre'],
        email: json['email'],
        contrasena: json['contrasena'],
        rol: json['rol'],
        estado_monitor: json['estado_monitor']
      );

  /// Convierte un UserModel a JSON (por ejemplo para API)
  Map<String, dynamic> toJson() => {
    if (id_usuario != null) 'id_usuario': id_usuario,
    'nombre': nombre,
    'email': email,
    'contrasena': contrasena,
    'rol': rol,             // en mayúsculas para Enum del backend
    'estado_monitor': estado_monitor.toLowerCase(), // usa el nombre exacto del modelo backend
  };

}
