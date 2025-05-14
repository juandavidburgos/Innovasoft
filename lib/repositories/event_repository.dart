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

  Future<List<EventModel>> obtenerEventosDelEntrenador(int idEntrenador) async {
    return await _localService.obtenerEventosAsignados(idEntrenador);
  }

  /*Future<int> asignarEntrenadoresAEvento(int eventoId, List<int> trainerIds) {
  return _localService.asignarEntrenadores(eventoId, trainerIds);
  }
  
  Future<List<EventModel>> obtenerEventosConEntrenadoresAsignados() {
  return _localService.obtenerEventosConEntrenadoresAsignados();
  }

  Future<List<Map<String, dynamic>>> obtenerEntrenadoresPorEvento(int eventoId) {
  return _localService.obtenerEntrenadoresPorEvento(eventoId);
  }*/

}