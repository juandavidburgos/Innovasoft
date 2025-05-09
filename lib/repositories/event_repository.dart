import '../models/event_model.dart';
import '../services/local_service.dart';

class EventRepository {
  final LocalService _localService = LocalService();

  Future<int> agregarEvento(EventModel evento) {
    return _localService.guardarEvento(evento);
  }

  Future<List<EventModel>> obtenerEventos() {
    return _localService.obtenerEventosActivos();
  }

  Future<int> actualizarEvento(EventModel evento) {
    return _localService.editarEvento(evento);
  }

  Future<int> deshabilitarEvento(int eventoId) {
    return _localService.inactivarEvento(eventoId);
  }

  Future<void> eliminarTodosEventos() {
  return _localService.eliminarTodosLosEventos();
  }

  Future<int> asignarMonitorAEvento(int eventoId, int monitorId) {
    return _localService.asignarMonitor(eventoId, monitorId);
  }
  
  Future<List<EventModel>> obtenerEventosConMonitoresAsignados() {
  return _localService.obtenerEventosConMonitoresAsignados();
  }


}