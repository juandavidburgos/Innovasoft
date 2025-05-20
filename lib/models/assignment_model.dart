/// Modelo de datos para representar la asignación de un entrenador a un evento.
class AssignmentModel {
  final int? id_asignacion;
  final int id_evento;
  final int id_usuario;

  AssignmentModel({
    this.id_asignacion,
    required this.id_evento,
    required this.id_usuario,
  });

  /// Convierte un Map (de SQLite) en un AssignmentModel.
  factory AssignmentModel.fromMap(Map<String, dynamic> map) => AssignmentModel(
        id_asignacion: map['id_asignacion'],
        id_evento: map['id_evento'],
        id_usuario: map['id_usuario'],
      );

  /// Convierte el AssignmentModel en un Map (para SQLite).
  Map<String, dynamic> toMap() => {
        if (id_asignacion != null) 'id_asignacion': id_asignacion,
        'id_evento': id_evento,
        'id_usuario': id_usuario,
      };

  /// Convierte un JSON (Map) en un AssignmentModel.
  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
        id_asignacion: json['id_asignacion'],
        id_evento: json['id_evento'],
        id_usuario: json['id_usuario'],
      );

  /// Convierte un AssignmentModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
    if (id_asignacion != null) 'id_asignacion': id_asignacion,
    'id_evento': id_evento,
    'id_usuario': id_usuario,
  };
}
