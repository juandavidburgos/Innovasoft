/// Modelo de datos para representar un evento deportivo.
class EventModel {
  final int? idEvento;
  final String nombre;
  final String ubicacion;
  final String fecha;
  final int? idUsuario;
  final String estado;

  EventModel({
    this.idEvento,
    required this.nombre,
    required this.ubicacion,
    required this.fecha,
    this.idUsuario,
    this.estado = 'activo'
  });

  /// Convierte un Map en un objeto EventModel.
  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        idEvento: map['id_evento'],
        nombre: map['nombre'],
        ubicacion: map['ubicacion'],
        fecha: map['fecha'],
        idUsuario: map['id_usuario'],
        estado: map['estado'],
      );

  /// Convierte un EventModel en un Map para uso general (local o remoto).
  Map<String, dynamic> toMap() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'fecha': fecha,
        'id_usuario': idUsuario,
        'estado': estado,
      };

  /// Convierte un JSON (Map) en un objeto EventModel (para HTTP).
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        idEvento: json['id_evento'],
        nombre: json['nombre'],
        ubicacion: json['ubicacion'],
        fecha: json['fecha'],
        idUsuario: json['id_usuario'],
        estado: json['estado'],
    );
  }

  /// Convierte un EventModel en JSON (para envío por HTTP).
  Map<String, dynamic> toJson() => {
        if (idEvento != null) 'id_evento': idEvento,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'fecha': fecha,
        'id_usuario': idUsuario,
        'estado': estado
      };
}
