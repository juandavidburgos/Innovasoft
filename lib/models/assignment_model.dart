/// Modelo de datos para representar la asignación de un entrenador a un evento.
class AssignmentModel {
  final int? idAsignacion;
  final int idEvento;
  final int idUsuario;

  AssignmentModel({
    this.idAsignacion,
    required this.idEvento,
    required this.idUsuario,
  });

  /// Convierte un Map (de SQLite) en un AssignmentModel.
  factory AssignmentModel.fromMap(Map<String, dynamic> map) => AssignmentModel(
        idAsignacion: map['id_asignacion'],
        idEvento: map['id_evento'],
        idUsuario: map['id_usuario'],
      );

  /// Convierte el AssignmentModel en un Map (para SQLite).
  Map<String, dynamic> toMap() => {
        if (idAsignacion != null) 'id_asignacion': idAsignacion,
        'id_evento': idEvento,
        'id_usuario': idUsuario,
      };

  /// Convierte un JSON (Map) en un AssignmentModel.
  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
        idAsignacion: json['id_asignacion'],
        idEvento: json['id_evento'],
        idUsuario: json['id_usuario'],
      );

  /// Convierte un AssignmentModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (idAsignacion != null) 'id_asignacion': idAsignacion,
        'id_evento': idEvento,
        'id_usuario': idUsuario,
      };
}
