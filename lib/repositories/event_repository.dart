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

  Future<int> deshabilitarEvento(int id) {
    return _localService.deshabilitarEvento(id);
  }

  Future<void> eliminarTodosEventos() {
  return _localService.eliminarTodosEventos();
  }

  Future<int> asignarMonitorAEvento(int eventoId, int monitorId) {
    return _localService.asignarMonitorAEvento(eventoId, monitorId);
  }
  
  Future<List<EventModel>> obtenerEventosConMonitoresAsignados() {
  return _localService.obtenerEventosConMonitoresAsignados();
  }


}