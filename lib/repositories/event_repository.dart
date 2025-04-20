import '../models/event_model.dart';
import '../services/local_service.dart';

class EventRepository {
  final LocalService _localService = LocalService();

  Future<int> agregarEvento(EventModel evento) {
    return _localService.insertEvento(evento);
  }

  Future<List<EventModel>> obtenerEventos() {
    return _localService.getEventos();
  }

  Future<int> actualizarEvento(EventModel evento) {
    return _localService.updateEvento(evento);
  }

  Future<int> eliminarEvento(int id) {
    return _localService.deleteEvento(id);
  }
}