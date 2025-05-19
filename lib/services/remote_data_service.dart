import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RemoteDataService {

  final String apiUrl = 'http://localhost:8080/api/eventos';
  final String apiUrlUsuarios = 'http://localhost:8080/api/usuarios';

  static final RemoteDataService dbR = RemoteDataService();

  /// Envía un nuevo evento al servidor mediante HTTP POST.
  ///
  /// Retorna `true` si el servidor responde con éxito (200 o 201).
  Future<bool> sendEvent(EventModel event) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Obtiene todos los eventos desde el servidor mediante HTTP GET.
  ///
  /// Si [soloActivos] es `true`, agrega un parámetro a la URL para filtrar.
  /// Retorna una lista de objetos `EventModel`.
  Future<List<EventModel>> fetchEventos({bool soloActivos = true}) async {
    try {
      final uri = Uri.parse(soloActivos ? '$apiUrl?estado=activo' : apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => EventModel.fromMap(e)).toList();
      } else {
        throw Exception('Error al obtener los eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualiza un evento existente en el servidor mediante HTTP PUT.
  ///
  /// Requiere que el evento tenga un `idEvento` válido.
  Future<bool> updateEvento(EventModel evento) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${evento.idEvento}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(evento.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Deshabilita un evento (cambia su estado a 'inactivo') mediante HTTP PATCH.
  Future<bool> deshabilitarEvento(int idEvento) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/$idEvento'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 'inactivo'}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Elimina un evento del servidor mediante HTTP DELETE.
  Future<bool> deleteEvento(int idEvento) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$idEvento'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  ///Metodos para usuario
  
  // Insertar un nuevo usuario
  Future<bool> sendUsuario(UserModel usuario) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlUsuarios),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Obtener todos los usuarios desde el servidor
  Future<List<UserModel>> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrlUsuarios));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener los usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar un usuario existente
  Future<bool> updateUsuario(UserModel usuario) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlUsuarios/${usuario.idUsuario}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Eliminar un usuario
  Future<bool> deleteUsuario(int idUsuario) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrlUsuarios/$idUsuario'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Verificar si un correo ya existe
  Future<bool> existeCorreo(String email) async {
    try {
      final response = await http.get(Uri.parse('$apiUrlUsuarios?email=$email'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.isNotEmpty;
      } else {
        throw Exception('Error al verificar el correo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<UserModel?> authUsuarioRemoto(String email, String password) async {
      final url = Uri.parse('https://tu-backend.com/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final decoded = json.decode(token);

        // Guardar token y sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt('id_usuario', decoded['id_usuario']);
        await prefs.setString('nombre', decoded['nombre']);
        await prefs.setString('rol', decoded['rol']);
        await prefs.setString('email', email);
        await prefs.setString('estado', decoded['estado']);

        return UserModel(
          idUsuario: decoded['id_usuario'],
          nombre: decoded['nombre'],
          email: email,
          contrasena: '', // no se guarda
          rol: decoded['rol'],
          estado: decoded['estado'],
        );
      }

      return null;
    }

    Future<void> logOutRemoto() async {
      final prefs = await SharedPreferences.getInstance();
      // Opcional: llamar al backend para invalidar token
      await http.post(Uri.parse('https://tu-api.com/logout'));

      await prefs.remove('jwt_token');
      await prefs.remove('id_usuario');
      await prefs.remove('nombre_usuario');
      await prefs.remove('email_usuario');
      await prefs.remove('rol_usuario');

  }
}