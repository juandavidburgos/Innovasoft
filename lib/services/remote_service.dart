import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import '../models/user_model.dart';

/// Servicio encargado de la comunicación con el back-end (API REST).
class RemoteService {
  final String apiUrl = 'http://localhost:8080/api/eventos';
  final String apiUrlUsuarios = 'http://localhost:8080/api/usuarios';

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

}
