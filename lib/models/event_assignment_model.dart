//REVISAR !!!!!!!!!!!!!!!!!!
class EventoAsignacionModel {
  final int id_evento;
  final String nombre;
  final String fecha_hora_inicio;
  final String fecha_hora_fin;
  final String ubicacion;
  final List<MonitorModel> monitoresAsignados;

  EventoAsignacionModel({
    required this.id_evento,
    required this.nombre,
    required this.fecha_hora_inicio,
    required this.fecha_hora_fin,
    required this.ubicacion,
    required this.monitoresAsignados,
  });

  factory EventoAsignacionModel.fromJson(Map<String, dynamic> json) {
    return EventoAsignacionModel(
      id_evento: json['id_evento'],
      nombre: json['nombre'],
      fecha_hora_inicio: json['fecha_hora_inicio'],
      fecha_hora_fin: json['fecha_hora_fin'],
      ubicacion: json['ubicacion'],
      monitoresAsignados: (json['monitores'] as List<dynamic>)
          .map((e) => MonitorModel.fromJson(e))
          .toList(),
    );
  }
}

class MonitorModel {
  final int id_usuario;
  final String nombre;
  final String email;
  final String contrasena;

  MonitorModel({
    required this.id_usuario,
    required this.nombre,
    required this.email,
    required this.contrasena,
  });

  factory MonitorModel.fromJson(Map<String, dynamic> json) {
    return MonitorModel(
      id_usuario: json['id_usuario'],
      nombre: json['nombre'],
      email: json['email'],
      contrasena: json['contrasena'],
    );
  }
}
