import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/form_model.dart';
import '../models/answer_model.dart';
import 'remote_data_service.dart';

/// Servicio encargado de la comunicación con el back-end (API REST).
class RemoteService {

/// -------------------------------------------------
  /// *MÉTODOS REMOTOS
  /// -------------------------------------------------

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A EVENTOS
  /// -------------------------------------------------

  /// Envía un evento al servidor utilizando el RemoteDataService.
  /// Retorna `true` si el evento fue creado correctamente.
  Future<bool> guardarEventoRemoto(EventModel evento) async {
    return await RemoteDataService.dbR.sendEvent(evento);
  }

  /// Obtiene todos los eventos desde el servidor mediante HTTP GET.
  ///
  Future<List<EventModel>> obtenerEventosRemotos() async {
    return await RemoteDataService.dbR.fetchEventos();
  }

  /// Actualiza parcialmente un evento utilizando RemoteDataService.
  Future<bool> actualizarEventoParcialRemoto(int idEvento, EventModel eventoParcial) async {
    return await RemoteDataService.dbR.updateEventoParcial(idEvento, eventoParcial);
  }

  /// Deshabilita un evento (cambia su estado a 'inactivo')
  Future<bool> desactivarEventoRemoto(int idEvento) async {
    return await RemoteDataService.dbR.desactivarEvento(idEvento);
  }

  /// Elimina un evento del servidor mediante HTTP DELETE.
  Future<bool> eliminarEventoRemoto(int idEvento) async {
    return await RemoteDataService.dbR.deleteEvento(idEvento);
  }

  Future<List<EventModel>> getEventosAsignadosRemotos(int idUsuario) async {
    return await RemoteDataService.dbR.getEventosAsignados(idUsuario);
  }
  
  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A USUARIOS
  /// -------------------------------------------------
  
  // Insertar un nuevo usuario
  Future<bool> guardarUsuarioRemoto(UserModel usuario) async {
    return await RemoteDataService.dbR.sendUsuario(usuario);
  }

  // Obtener todos los usuarios desde el servidor
  Future<List<UserModel>> buscarUsuariosRemoto() async {
    return await RemoteDataService.dbR.fetchUsuarios();
  }

  // Actualizar un usuario existente
  Future<bool> actualizarUsuarioRemoto(UserModel usuario) async {
    return await RemoteDataService.dbR.updateUsuario(usuario);
  }

  // Eliminar un usuario
  Future<bool> eliminarUsuarioRemoto(int idUsuario) async {
    return await RemoteDataService.dbR.deleteUsuario(idUsuario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS DE ASIGNACIONES
  /// -------------------------------------------------
  // Asignar entrenador a evento
  Future<bool> asignarEntrenadorAEventoRemoto(int idUsuario, int idEvento) async {
    return await RemoteDataService.dbR.asignarEntrenadorAEvento(idUsuario, idEvento);
  }

  Future<List<EventModel>> obtenerEventosAsignadosRemoto(int idUsuario) async{
    return await RemoteDataService.dbR.getEventosAsignados(idUsuario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS DE FORMULARIOS
  /// -------------------------------------------------

  Future<bool> enviarFormularioRespondido(FormModel formulario, List<AnswerModel> respuestas) async {
    return await RemoteDataService.dbR.sendFormularioRespondido(formulario, respuestas);
  }

  Future<bool> enviarEvidencia(FormModel formulario) async {
    return await RemoteDataService.dbR.sendEvidence(formulario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS DE AUTENTICACIÓN DE USUARIOS
  /// -------------------------------------------------

  // Verificar si un correo ya existe
  Future<bool> existeCorreoRemoto(String email) async {
    return await RemoteDataService.dbR.existeCorreo(email);
  }

  Future<UserModel?> autenticarUsuarioRemoto(String email, String password) async {
    return await RemoteDataService.dbR.authUsuarioRemoto(email, password);
  }
}
