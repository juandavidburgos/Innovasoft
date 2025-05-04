import 'package:intl/intl.dart';

/// Modelo de datos para representar un evento deportivo.
class EventModel {
  final int? idEvento;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  //final DateTime fecha;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final int? idUsuario;
  final String estado;

  // Formatter para fechas y horas
  static final DateFormat _formatter = DateFormat('dd-MM-yyyy HH:mm');

  EventModel({
    this.idEvento,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    this.idUsuario,
    this.estado = 'activo',
  });

  /// Convierte un Map en un objeto EventModel(para SQLite).
  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        idEvento: map['id_evento'],
        nombre: map['nombre'],
        descripcion: map['descripcion'],
        ubicacion: map['ubicacion'],
        fechaHoraInicio: map['fecha_hora_inicio'] != null
            ? _formatter.parse(map['fecha_hora_inicio'])
            : DateTime.now(),
        fechaHoraFin: map['fecha_hora_fin'] != null
            ? _formatter.parse(map['fecha_hora_fin'])
            : DateTime.now().add(Duration(hours: 1)),
        idUsuario: map['id_usuario'],
        estado: map['estado'],
      );

  /// Convierte un EventModel en un Map para SQLite.
  Map<String, dynamic> toMap() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'fecha_hora_inicio': _formatter.format(fechaHoraInicio),
        'fecha_hora_fin': _formatter.format(fechaHoraFin),
        'id_usuario': idUsuario,
        'estado': estado,
      };

  /// Convierte un JSON (Map) en un objeto EventModel.
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        idEvento: json['id_evento'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        ubicacion: json['ubicacion'],
        fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
        fechaHoraFin: DateTime.parse(json['fecha_hora_fin']),
        idUsuario: json['id_usuario'],
        estado: json['estado'],
      );

  /// Convierte un EventModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
        'fecha_hora_fin': fechaHoraFin.toIso8601String(),
        'id_usuario': idUsuario,
        'estado': estado,
      };
}

