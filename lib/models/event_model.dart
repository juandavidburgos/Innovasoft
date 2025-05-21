import 'package:intl/intl.dart';

/// Modelo de datos para representar un evento deportivo.
class EventModel {
  final int? id_evento;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  //final DateTime fecha;
  final DateTime fecha_hora_inicio;
  final DateTime fecha_hora_fin;
  //final int? id_usuario;
  final String estado;

  // Formatter para fechas y horas
  static final DateFormat _formatter = DateFormat('dd-MM-yyyy HH:mm');

  static DateTime _parseFechaDinamica(String fecha) {
  try {
    return DateTime.parse(fecha); // ISO 8601
  } catch (_) {
    try {
      return DateFormat('dd-MM-yyyy HH:mm').parse(fecha); // formato manual
    } catch (e) {
      throw FormatException('Formato de fecha inválido: $fecha');
    }
  }
}


  EventModel({
    this.id_evento,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha_hora_inicio,
    required this.fecha_hora_fin,
    //this.id_usuario,
    this.estado = 'activo',
  });

  /// Convierte un Map en un objeto EventModel(para SQLite).
  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        id_evento: map['id_evento'],
        nombre: map['nombre'],
        descripcion: map['descripcion'],
        ubicacion: map['ubicacion'],
        fecha_hora_inicio: map['fecha_hora_inicio'] != null
            ? _parseFechaDinamica(map['fecha_hora_inicio'])
            : DateTime.now(),
        fecha_hora_fin: map['fecha_hora_fin'] != null
          ? _parseFechaDinamica(map['fecha_hora_fin']) // ✔️ Correcto para '2025-05-31T14:21:00.000'
          : DateTime.now().add(Duration(hours: 1)),
       // id_usuario: map['id_usuario'],
        estado: map['estado'],
      );

  /// Convierte un EventModel en un Map para SQLite.
  Map<String, dynamic> toMap() => {
        if (id_evento != null) 'id_evento': id_evento,
        'nombre': nombre,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'fecha_hora_inicio': _formatter.format(fecha_hora_inicio),
        'fecha_hora_fin': _formatter.format(fecha_hora_fin),
        //'id_usuario': id_usuario,
        'estado': estado,
      };

  /// Convierte un JSON (Map) en un objeto EventModel.
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id_evento: json['id_evento'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        ubicacion: json['ubicacion'],
        fecha_hora_inicio: DateTime.parse(json['fecha_hora_inicio']),
        fecha_hora_fin: DateTime.parse(json['fecha_hora_fin']),
       // id_usuario: json['id_usuario'],
        estado: json['estado'],
      );

  /// Convierte un EventModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (id_evento != null) 'id_evento': id_evento,
        'nombre': nombre,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'fecha_hora_inicio': fecha_hora_inicio.toIso8601String(),
        'fecha_hora_fin': fecha_hora_fin.toIso8601String(),
        'estado': estado,
      };
}

