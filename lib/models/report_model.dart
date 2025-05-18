import '../models/event_model.dart';
import '../models/user_model.dart';

class Reporte {
  final EventModel evento;
  final UserModel usuario;
  final List<Map<String, dynamic>> asistentes;

  Reporte({
    required this.evento,
    required this.usuario,
    required this.asistentes,
  });

  Map<String, dynamic> toJson() {
    return {
      'evento': evento.toJson(),
      'usuario': usuario.toJson(),
      'asistentes': asistentes,
    };
  }
}
