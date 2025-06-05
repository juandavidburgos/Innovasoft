import 'package:intl/intl.dart';

/// Modelo de datos para representar un formulario asociado a un evento.
class FormModel {
  final int? id_formulario;
  final int? id_evento;
  final int? id_usuario;
  final String titulo;
  final String descripcion;
  final DateTime fecha_creacion;
  final double? latitud;
  final double? longitud;
  final String? path_imagen;

  static final DateFormat _formatter = DateFormat('dd-MM-yyyy HH:mm');

  FormModel({
    this.id_formulario,
    this.id_evento,
    this.id_usuario,
    required this.titulo,
    required this.descripcion,
    required this.fecha_creacion,
    this.latitud,
    this.longitud,
    this.path_imagen,
  });

  /// Convierte un Map en un objeto FormModel (para SQLite).
  factory FormModel.fromMap(Map<String, dynamic> map) => FormModel(
        id_formulario: map['id_formulario'],
        id_evento: map['id_evento'],
        id_usuario: map['usuario_id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        fecha_creacion: map['fecha_creacion'] != null
            ? _formatter.parse(map['fecha_creacion'])
            : DateTime.now(),
        latitud: map['latitud'] != null ? map['latitud'] * 1.0 : null,
        longitud: map['longitud'] != null ? map['longitud'] * 1.0 : null,
        path_imagen: map['path_imagen'],
      );

  /// Convierte un FormModel en un Map (para SQLite).
  Map<String, dynamic> toMap() => {
    if (id_formulario != null) 'id_formulario': id_formulario,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha_creacion': fecha_creacion.toIso8601String(),
    'id_evento': id_evento,
    'id_usuario': id_usuario,
    'latitud': latitud,
    'longitud': longitud,
    'path_imagen': path_imagen,
  };


  /// Convierte un JSON (Map) en un objeto FormModel.
  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
    id_formulario: json['id_formulario'],
    id_evento: json['id_evento'],
    id_usuario: json['id_usuario'], // ← aquí estaba el error
    titulo: json['titulo'],
    descripcion: json['descripcion'],
    fecha_creacion: DateTime.parse(json['fecha_creacion']),
    latitud: (json['latitud'] != null) ? json['latitud'].toDouble() : null,
    longitud: (json['longitud'] != null) ? json['longitud'].toDouble() : null,
    path_imagen: json['path_imagen'],
  );


  /// Convierte un FormModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (id_formulario != null) 'id_formulario': id_formulario,
        'id_evento': id_evento,
        'usuario_id': id_usuario,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_creacion': fecha_creacion.toIso8601String(),
        'latitud': latitud,
        'longitud': longitud,
        'path_imagen': path_imagen,
      };

      FormModel copyWith({int? id_formulario}) {
        return FormModel(
          id_formulario: id_formulario ?? this.id_formulario,
          id_evento: id_evento,
          id_usuario: id_usuario,
          titulo: titulo,
          descripcion: descripcion,
          fecha_creacion: fecha_creacion,
          latitud: latitud,
          longitud: longitud,
          path_imagen: path_imagen,
        );
      }

    /*Map<String, dynamic> toJsonBackend() => {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_creacion': fecha_creacion.toIso8601String(),
      'objEvento': {
        'id_evento': id_evento,
      },
      'usuario': {
        'id_usuario': id_usuario,
      },
    };*/


}
