import '../models/assignment_model.dart';
import '../models/event_model.dart';
import '../services/local_service.dart';

class AssignmentRepository {
  
  final LocalService _localService = LocalService();

  /// Asigna múltiples entrenadores a un evento
  Future<int> asignarEntrenadoresAEvento(int eventoId, List<int> trainerIds) {
    return _localService.asignarEntrenadores(eventoId, trainerIds);
  }

  /// Retorna una lista de eventos con entrenadores ya asignados
  /*Future<List<EventModel>> obtenerEventosConEntrenadoresAsignados() {
    return _localService.obtenerEventosConEntrenadoresAsignados();
  }*/
  Future<List<Map<String, dynamic>>> obtenerEventosConEntrenadoresAsignados() {
    // Llamamos al servicio que obtiene los eventos con los entrenadores asignados
    return _localService.obtenerEventosConEntrenadoresAsignados();
  }

  /// Obtiene entrenadores asignados a un evento específico
  Future<List<Map<String, dynamic>>> obtenerEntrenadoresPorEvento(int eventoId) {
    return _localService.obtenerEntrenadoresPorEvento(eventoId);
  }

  /// (Opcional) Método para eliminar una asignación
  /*Future<int> eliminarAsignacion(int idAsignacion) {
    return _localService.eliminarAsignacion(idAsignacion);
  }*/
}
