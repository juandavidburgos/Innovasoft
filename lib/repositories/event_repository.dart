import 'package:basic_flutter/services/remote_service.dart';

import '../models/event_model.dart';
import '../services/local_service.dart';

class EventRepository {
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();

  ///
  /// MÉTODOS DE GESTIÓN LOCAL
  /// 

  /// --------------------------------------------------------
  /// Gestión de eventos:
  /// 

  Future<int> agregarEvento(EventModel evento) {
    return _localService.guardarEvento(evento);
  }

  Future<void> agregarListaDeEventos(List<EventModel> eventos) async {
    return _localService.guardarEventosLocalmente(eventos);
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

  ///
  /// MÉTODOS DE GESTIÓN ONLINE
  /// 
  /// --------------------------------------------------------
  /// Gestión de eventos:
  /// 
  
  Future<List<EventModel>> obtenerEventosAsignadosRemotos(int idUsuario) async {
    return await _remoteService.getEventosAsignadosRemotos(idUsuario);
  }
  
}