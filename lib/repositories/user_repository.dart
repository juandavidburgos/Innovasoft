import 'package:basic_flutter/services/auth_service.dart';

import '../models/user_model.dart';
import '../services/local_service.dart';
import '../services/remote_service.dart';

class UserRepository {
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();
  final AuthService _authService = AuthService();

  /// Inserta un usuario en la base de datos local
  Future<int> agregarUsuario(UserModel usuario) {
    return _localService.guardarUsuario(usuario);
  }

  /// Retorna todos los usuarios almacenados localmente
  Future<List<UserModel>> obtenerUsuariosEntrenadoresActivos() {
    return _localService.obtenerEntrenadoresActivos();
  }

  Future<List<UserModel>> obtenerTodosEntrenadores() async{
    return _localService.obtenerEntrenadores();
  }

  Future<List<UserModel>> obtenerUsuarios(){
    return _localService.obtenerUsuarios();
  }

  Future<int> eliminarUsuario(int id) async{
    return _localService.eliminarUsuario(id);
  }

  Future<int> deshabilitarEntrenador(int id) async{
    return _localService.deshabilitarEntrenador(id);
  }

  /// Actualiza un usuario en la base de datos local
  Future<int> actualizarUsuario(UserModel usuario) {
    return _localService.editarUusario(usuario);
  }

  Future<UserModel?> autenticarUsuarioLocal(String email, password){
    return _authService.localLogin(email, password);
  }

  /// Verifica remotamente si un correo ya está registrado
  Future<bool> existeCorreoRemoto(String email) {
    return _remoteService.existeCorreoRemoto(email);
  }

  /// Envía un nuevo usuario al servidor remoto
  Future<bool> enviarUsuarioRemoto(UserModel usuario) {
    return _remoteService.guardarUsuarioRemoto(usuario);
  }

  /// Obtiene la lista de usuarios desde el servidor
  Future<List<UserModel>> obtenerUsuariosRemotos() {
    return _remoteService.buscarUsuariosRemoto();
  }

  /// Actualiza un usuario existente en el servidor
  Future<bool> actualizarUsuarioRemoto(UserModel usuario) {
    return _remoteService.actualizarUsuarioRemoto(usuario);
  }

  /// Elimina un usuario del servidor
  Future<bool> eliminarUsuarioRemoto(int idUsuario) {
    return _remoteService.eliminarUsuarioRemoto(idUsuario);
  }

  /// --- MÉTODOS DE SINCRONIZACIÓN ---

  /// Sincroniza usuarios remotos con la base de datos local (descarga remota → inserta local)
  Future<void> sincronizarDesdeServidor() async {
    final usuariosRemotos = await obtenerUsuariosRemotos();
    for (var user in usuariosRemotos) {
      final existe = await _localService.verificarUsuarioPorCorreo(user.email);
      if (!existe) {
        await agregarUsuario(user);
      } else {
        await actualizarUsuario(user);
      }
    }
  }

  /// Sincroniza usuarios locales con el servidor (local → remoto)
  /// útil para cuando hay conexión intermitente y se insertan datos offline
  Future<void> sincronizarHaciaServidor() async {
    final usuariosLocales = await obtenerUsuarios();
    for (var user in usuariosLocales) {
      final correoExiste = await existeCorreoRemoto(user.email);
      if (!correoExiste) {
        await enviarUsuarioRemoto(user);
      } else {
        await actualizarUsuarioRemoto(user);
      }
    }
  }

  /// Sincroniza en ambos sentidos: primero descarga y luego sube
  Future<void> sincronizarTodo() async {
    await sincronizarDesdeServidor();
    await sincronizarHaciaServidor();
  }

}
