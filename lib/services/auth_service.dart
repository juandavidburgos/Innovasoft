import '../models/user_model.dart';
import 'dart:async';
import '../services/data_service.dart';

class AuthService {
  Future<UserModel?> login(String email, String password) async {
    return await DatabaseService.db.autenticarUsuario(email, password);
  }
}
