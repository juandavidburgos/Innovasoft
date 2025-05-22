import 'package:basic_flutter/services/remote_data_service.dart';

import '../models/user_model.dart';
import 'dart:async';
import 'local_data_service.dart';

class AuthService {

  /// --------------------------------
  /// *MÉTODOS DE AUTENTICACIÓN LOCAL
  /// --------------------------------

  Future<UserModel?> localLogin(String email, String password) async {
    return await LocalDataService.db.autenticarUsuario(email, password);
  }

  Future<void> cerrarSesionLocal() async {
    return await LocalDataService.db.logOutLocal();
  }

  /// ---------------------------------
  /// *MÉTODOS DE AUTENTICACIÓN REMOTA
  /// ---------------------------------

  Future<UserModel?> remoteLogin(String email, String password) async {
    return await RemoteDataService.dbR.authUsuarioRemoto(email, password);
    //throw Exception('Simulación: login remoto deshabilitado'); //--> Simular back-end deshabilitado
  }

  Future<void> cerrarSesionRemoto() async {
    return await RemoteDataService.dbR.logOutRemoto();
  }
}
