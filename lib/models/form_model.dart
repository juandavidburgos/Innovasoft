import 'package:intl/intl.dart';

/// Modelo de datos para representar un formulario asociado a un evento.
class FormModel {
  final int? idFormulario;
  final int? eventoId;
  final int? usuarioId;
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final double? latitud;
  final double? longitud;
  final String? pathImagen;

  static final DateFormat _formatter = DateFormat('dd-MM-yyyy HH:mm');

  FormModel({
    this.idFormulario,
    this.eventoId,
    this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    this.latitud,
    this.longitud,
    this.pathImagen,
  });

  /// Convierte un Map en un objeto FormModel (para SQLite).
  factory FormModel.fromMap(Map<String, dynamic> map) => FormModel(
        idFormulario: map['id_formulario'],
        eventoId: map['evento_id'],
        usuarioId: map['usuario_id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        fechaCreacion: map['fecha_creacion'] != null
            ? _formatter.parse(map['fecha_creacion'])
            : DateTime.now(),
        latitud: map['latitud'] != null ? map['latitud'] * 1.0 : null,
        longitud: map['longitud'] != null ? map['longitud'] * 1.0 : null,
        pathImagen: map['path_imagen'],
      );

  /// Convierte un FormModel en un Map (para SQLite).
  Map<String, dynamic> toMap() => {
        if (idFormulario != null) 'id_formulario': idFormulario,
        'evento_id': eventoId,
        'usuario_id': usuarioId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_creacion': _formatter.format(fechaCreacion),
        'latitud': latitud,
        'longitud': longitud,
        'path_imagen': pathImagen,
      };

  /// Convierte un JSON (Map) en un objeto FormModel.
  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
        idFormulario: json['id_formulario'],
        eventoId: json['evento_id'],
        usuarioId: json['usuario_id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        fechaCreacion: DateTime.parse(json['fecha_creacion']),
        latitud: (json['latitud'] != null) ? json['latitud'].toDouble() : null,
        longitud: (json['longitud'] != null) ? json['longitud'].toDouble() : null,
        pathImagen: json['path_imagen'],
      );

  /// Convierte un FormModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (idFormulario != null) 'id_formulario': idFormulario,
        'evento_id': eventoId,
        'usuario_id': usuarioId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        'latitud': latitud,
        'longitud': longitud,
        'path_imagen': pathImagen,
      };
}
