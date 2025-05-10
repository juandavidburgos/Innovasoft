class QuestionModel {
  final int? id;
  final int formularioId;
  final String contenido;
  final String tipo; // Ej: Texto, Número, Opción, Fecha, Si/No
  final bool esObligatoria;

  QuestionModel({
    this.id,
    required this.formularioId,
    required this.contenido,
    required this.tipo,
    this.esObligatoria = false,
  });

  /// Convierte un Map (SQLite) a QuestionModel
  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
        id: map['id'],
        formularioId: map['formulario_id'],
        contenido: map['contenido'],
        tipo: map['tipo'],
        esObligatoria: map['es_obligatoria'] == 1,
      );

  /// Convierte un QuestionModel a Map (SQLite)
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'formulario_id': formularioId,
        'contenido': contenido,
        'tipo': tipo,
        'es_obligatoria': esObligatoria ? 1 : 0,
      };

  /// Convierte un JSON a QuestionModel
  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'],
        formularioId: json['formulario_id'],
        contenido: json['contenido'],
        tipo: json['tipo'],
        esObligatoria: json['es_obligatoria'] ?? false,
      );

  /// Convierte un QuestionModel a JSON
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'formulario_id': formularioId,
        'contenido': contenido,
        'tipo': tipo,
        'es_obligatoria': esObligatoria,
      };
}
