class AnswerModel {
  final int? id_respuesta;
  final int pregunta_id;
  final int formulario_id;
  final int id_evento;
  final String contenido;

  AnswerModel({
    this.id_respuesta,
    required this.pregunta_id,
    required this.formulario_id,
    required this.id_evento,
    required this.contenido,
  });

  /// Convierte un Map (SQLite) a AnswerModel
  factory AnswerModel.fromMap(Map<String, dynamic> map) => AnswerModel(
        id_respuesta: map['id_respuesta'],
        pregunta_id: map['pregunta_id'],
        formulario_id: map['formulario_id'],
        id_evento: map['id_evento'],
        contenido: map['contenido'],
      );

  /// Convierte un AnswerModel a Map (SQLite)
  Map<String, dynamic> toMap() => {
        if (id_respuesta != null) 'id_respuesta': id_respuesta,
        'pregunta_id_respuesta': pregunta_id,
        'formulario_id': formulario_id,
        'id_evento':id_evento,
        'contenido': contenido,
      };

  /// Convierte un JSON a AnswerModel
  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
        id_respuesta: json['id_respuesta'],
        pregunta_id: json['pregunta_id'],
        formulario_id: json['formulario_id'],
        id_evento:json['id_evento'],
        contenido: json['contenido'],
      );

  Map<String, dynamic> toJsonCompleto() => {
    if (id_respuesta != null) 'idRespuesta': id_respuesta,
    'preguntaId': pregunta_id,             // ✅ Exacto al DTO del backend
    'contenido': contenido,
    'formularioId': formulario_id,         // ✅ Exacto al DTO del backend
    'idEvento': id_evento                  // ✅ Exacto al DTO del backend
  };


  Map<String, dynamic> toJson() => {
  'pregunta_id': pregunta_id,
  'contenido': contenido,
};

}
