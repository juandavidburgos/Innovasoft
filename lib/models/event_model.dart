import 'package:intl/intl.dart';

/// Modelo de datos para representar un evento deportivo.
class EventModel {
  final int? idEvento;
  final String nombre;
  final String ubicacion;
  final DateTime fecha;
  final int? idUsuario;
  final String estado;

  // Formatter para fechas en formato 'dd-MM-yyyy'
  static final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  EventModel({
    this.idEvento,
    required this.nombre,
    required this.ubicacion,
    required this.fecha,
    this.idUsuario,
    this.estado = 'activo',
  });

  /// Convierte un Map en un objeto EventModel.
  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        idEvento: map['id_evento'],
        nombre: map['nombre'],
        ubicacion: map['ubicacion'],
        fecha: map['fecha'] != null && map['fecha'].toString().isNotEmpty
            ? _formatter.parse(map['fecha'])  // Aquí está el cambio
            : DateTime.now(),
        idUsuario: map['id_usuario'],
        estado: map['estado'],
      );

  /// Convierte un EventModel en un Map para SQLite.
  Map<String, dynamic> toMap() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'fecha': _formatter.format(fecha), // Formato compatible con tu DB
        'id_usuario': idUsuario,
        'estado': estado,
      };

  /// Convierte un JSON (Map) en un objeto EventModel.
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        idEvento: json['id_evento'],
        nombre: json['nombre'],
        ubicacion: json['ubicacion'],
        fecha: DateTime.parse(json['fecha']), // asume ISO
        idUsuario: json['id_usuario'],
        estado: json['estado'],
      );

  /// Convierte un EventModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'fecha': fecha.toIso8601String(),
        'id_usuario': idUsuario,
        'estado': estado,
      };
}

