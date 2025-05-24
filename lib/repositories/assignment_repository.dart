import '../services/remote_service.dart';
import '../services/local_service.dart';
import '../models/event_model.dart';

class AssignmentRepository {
  
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();                       

  /// -------------------------------------------------
  /// MÉTODOS DE GESTIÓN LOCAL
  /// -------------------------------------------------

  /// Asigna entrenador a un evento
  Future<bool> asignarEntrenadorAEvento(int eventoId, int trainerId) {
    return _localService.asignarEntrenador(eventoId, trainerId);
  }

  /// Asigna múltiples entrenadores a un evento
  Future<int> asignarEntrenadoresAEvento(int eventoId, List<int> trainerIds) {
    return _localService.asignarEntrenadores(eventoId, trainerIds);
  }

  /// Obtiene eventos con entrenadores asignados
  Future<List<Map<String, dynamic>>> obtenerEventosConEntrenadoresAsignados() {
    // Llamamos al servicio que obtiene los eventos con los entrenadores asignados
    return _localService.obtenerEventosConEntrenadoresAsignados();
  }

  /// Actualiza la lista de entrenadores asignados a un evento
  Future<bool> actualizarAsignacionesDeEvento(int eventoId, List<int> trainerIds) {
    return _localService.actualizarAsignacionesDeEvento(eventoId, trainerIds);
  }

  /// Actualiza la lista de eventos asignados a un monitor
  Future<bool> actualizarEventosDeMonitor(int monitorId, List<int> eventosIds) {
    return _localService.actualizarAsignacionesDeMonitor(monitorId, eventosIds);
  }

  /// Obtiene las asignaciones con el nombre del evento (para dropdown)
  Future<List<Map<String, dynamic>>> obtenerAsignacionesConNombreEvento() {
    return _localService.obtenerAsignacionesConNombreEvento();
  }

  /// Obtiene los entrenadores asignados a un evento específico
  Future<List<Map<String, dynamic>>> obtenerEntrenadoresPorEvento(int eventoId) {
    return _localService.obtenerEntrenadoresPorEvento(eventoId);
  }

  Future<List<EventModel>> obtenerEventosDelMonitor(int idEntrenador) async {
    return await _localService.obtenerEventosAsignados(idEntrenador);
  }


  /// (Opcional) Método para eliminar una asignación
  /*Future<int> eliminarAsignacion(int idAsignacion) {
    return _localService.eliminarAsignacion(idAsignacion);
  }*/

  /// -------------------------------------------------
  /// MÉTODOS DE GESTIÓN REMOTA
  /// -------------------------------------------------

  Future<bool> asignarEntrenadorAEventoRemoto(int idUsuario, int idEvento) async {
    return await _remoteService.asignarEntrenadorAEventoRemoto(idUsuario, idEvento);
  }

  // Modificar asignación de entrenador de un evento a otro
  Future<bool> modificarAsignacionEntrenadorRemoto(int idUsuario, int idEvento, int nuevoIdEvento) async {
    return await _remoteService.modificarAsignacionEntrenadorRemoto(idUsuario, idEvento, nuevoIdEvento);
  }

  Future<List<EventModel>> getEventosAsignados(int idUsuario) async{
    return _remoteService.obtenerEventosAsignadosRemoto(idUsuario);
  }
}
