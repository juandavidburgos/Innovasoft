import '../models/user_model.dart';
import '../services/local_service.dart';
import '../services/remote_service.dart';

class UserRepository {
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();

  /// Inserta un usuario en la base de datos local
  Future<int> agregarUsuario(UserModel usuario) {
    return _localService.insertUsuario(usuario);
  }

  /// Retorna todos los usuarios almacenados localmente
  Future<List<UserModel>> obtenerUsuarios() {
    return _localService.getUsuarios();
  }

  /// Actualiza un usuario en la base de datos local
  Future<int> actualizarUsuario(UserModel usuario) {
    return _localService.updateUsuario(usuario);
  }

  /// Verifica remotamente si un correo ya está registrado
  Future<bool> existeCorreoRemoto(String email) {
    return _remoteService.existeCorreo(email);
  }

  /// Envía un nuevo usuario al servidor remoto
  Future<bool> enviarUsuarioRemoto(UserModel usuario) {
    return _remoteService.sendUsuario(usuario);
  }

  /// Obtiene la lista de usuarios desde el servidor
  Future<List<UserModel>> obtenerUsuariosRemotos() {
    return _remoteService.fetchUsuarios();
  }

  /// Actualiza un usuario existente en el servidor
  Future<bool> actualizarUsuarioRemoto(UserModel usuario) {
    return _remoteService.updateUsuario(usuario);
  }

  /// Elimina un usuario del servidor
  Future<bool> eliminarUsuarioRemoto(int idUsuario) {
    return _remoteService.deleteUsuario(idUsuario);
  }

  /// --- MÉTODOS DE SINCRONIZACIÓN ---

  /// Sincroniza usuarios remotos con la base de datos local (descarga remota → inserta local)
  Future<void> sincronizarDesdeServidor() async {
    final usuariosRemotos = await obtenerUsuariosRemotos();
    for (var user in usuariosRemotos) {
      final existe = await _localService.existeUsuarioPorCorreo(user.email);
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
