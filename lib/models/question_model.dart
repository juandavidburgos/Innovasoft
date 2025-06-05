class QuestionModel {
  final int? id_pregunta;
  final int formulario_id;
  final String contenido;
  final String tipo; // Ej: Texto, Número, Opción, Fecha, Si/No
  final bool obligatoria;

  QuestionModel({
    this.id_pregunta,
    required this.formulario_id,
    required this.contenido,
    required this.tipo,
    this.obligatoria = false,
  });

  /// Convierte un Map (SQLite) a QuestionModel
  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
        id_pregunta: map['id_pregunta'],
        formulario_id: map['formulario_id'],
        contenido: map['contenido'],
        tipo: map['tipo'],
        obligatoria: (map['obligatoria'] ?? 1 )== 1,
      );

  /// Convierte un QuestionModel a Map (SQLite)
  Map<String, dynamic> toMap() => {
        if (id_pregunta != null) 'id_pregunta': id_pregunta,
        'formulario_id': formulario_id,
        'contenido': contenido,
        'tipo': tipo,
        'obligatoria': obligatoria ? 1 : 0,
      };

  /// Convierte un JSON a QuestionModel
  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id_pregunta: json['id_pregunta'],
        formulario_id: json['formulario_id'],
        contenido: json['contenido'],
        tipo: json['tipo'],
        obligatoria: json['obligatoria'] ?? false,
      );

  /// Convierte un QuestionModel a JSON
  Map<String, dynamic> toJson() => {
        if (id_pregunta != null) 'id_pregunta': id_pregunta,
        'formulario_id': formulario_id,
        'contenido': contenido,
        'tipo': tipo,
        'obligatoria': obligatoria,
      };
}
