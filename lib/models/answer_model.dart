class AnswerModel {
  final int? id;
  final int preguntaId;
  final int formularioId;
  final String contenido;

  AnswerModel({
    this.id,
    required this.preguntaId,
    required this.formularioId,
    required this.contenido,
  });

  /// Convierte un Map (SQLite) a AnswerModel
  factory AnswerModel.fromMap(Map<String, dynamic> map) => AnswerModel(
        id: map['id'],
        preguntaId: map['pregunta_id'],
        formularioId: map['formulario_id'],
        contenido: map['contenido'],
      );

  /// Convierte un AnswerModel a Map (SQLite)
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'pregunta_id': preguntaId,
        'formulario_id': formularioId,
        'contenido': contenido,
      };

  /// Convierte un JSON a AnswerModel
  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
        id: json['id'],
        preguntaId: json['pregunta_id'],
        formularioId: json['formulario_id'],
        contenido: json['contenido'],
      );

  /// Convierte un AnswerModel a JSON
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pregunta_id': preguntaId,
        'formulario_id': formularioId,
        'contenido': contenido,
      };
}
