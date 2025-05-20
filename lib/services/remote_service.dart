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

  /// Envía un nuevo evento al servidor mediante HTTP POST.
  ///
  /// Retorna `true` si el servidor responde con éxito (200 o 201).
  Future<bool> guardarEventoRemoto(EventModel event) async {
    return await RemoteDataService.dbR.sendEvent(event);
  }

  /// Obtiene todos los eventos desde el servidor mediante HTTP GET.
  ///
  /// Si [soloActivos] es `true`, agrega un parámetro a la URL para filtrar.
  /// Retorna una lista de objetos `EventModel`.
  Future<List<EventModel>> buscarEventosRemoto({bool soloActivos = true}) async {
    return await RemoteDataService.dbR.fetchEventos();
  }

  /// Actualiza un evento existente en el servidor mediante HTTP PUT.
  ///
  /// Requiere que el evento tenga un `idEvento` válido.
  Future<bool> actualizarEventoRemoto (EventModel evento) async {
    return await RemoteDataService.dbR.updateEvento(evento);
  }

  /// Deshabilita un evento (cambia su estado a 'inactivo') mediante HTTP PATCH.
  Future<bool> deshabilitarEventoRemoto(int idEvento) async {
    return await RemoteDataService.dbR.deshabilitarEvento(idEvento);
  }

  /// Elimina un evento del servidor mediante HTTP DELETE.
  Future<bool> eliminarEventoRemoto(int idEvento) async {
    return await RemoteDataService.dbR.deleteEvento(idEvento);
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

  Future<List<EventModel>> obtenerEventosAsignadosRemoto(int idUsuario) async{
    return await RemoteDataService.dbR.getEventosAsignados(idUsuario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS DE FORMULARIOS
  /// -------------------------------------------------

  Future<bool> enviarFormularioRespondido(FormModel formulario, List<AnswerModel> respuestas) async {
    return await RemoteDataService.dbR.sendFormularioRespondido(formulario, respuestas);
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
