import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/services/local_data_service.dart';
import 'package:basic_flutter/services/local_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/answer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RemoteDataService {

  /// -------------------------------------------------
  /// *MÉTODOS REMOTOS
  /// -------------------------------------------------

  // Url del api
  final String apiUrl = 'http://localhost:8080/api/eventos';
  final String apiUrlUsuarios = 'http://localhost:8080/api/usuarios';

  static final RemoteDataService dbR = RemoteDataService();

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A EVENTOS
  /// -------------------------------------------------

  /// Envía un nuevo evento al servidor mediante HTTP POST.
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
        Uri.parse('$apiUrl/${evento.id_evento}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(evento.toJson()),
        );
        return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //OTRA OPCION
  /// Actualiza un evento existente en el servidor mediante HTTP PATCH.
  ///
  /// Requiere que el evento tenga un id_evento válido.
  Future<bool> updateEventoAlternativo(EventModel evento) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/${evento.id_evento}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "nombre": evento.nombre,
          "descripcion": evento.descripcion,
          "ubicacion": evento.ubicacion,
          "fecha_hora_inicio": evento.fecha_hora_inicio.toIso8601String(),
          "fecha_hora_fin": evento.fecha_hora_fin.toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando evento: $e');
      return false;
    }
  }

  /// Desactiva (deshabilita) un evento haciendo una solicitud DELETE.
  Future<bool> deshabilitarEvento(int idEvento) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$idEvento'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Deshabilita un evento (cambia su estado a 'inactivo') mediante HTTP PATCH.
  /*Future<bool> deshabilitarEvento(int idEvento) async {
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
  }*/

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
  
  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LOS USUARIOS
  /// -------------------------------------------------
  
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
        Uri.parse('$apiUrlUsuarios/${usuario.id_usuario}'),
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


  /// -------------------------------------------------
  /// *MÉTODOS DE ASIGNACIONES
  /// -------------------------------------------------
  /// 
  
  /// Asigna un entrenador a un evento mediante una solicitud HTTP POST.
  Future<bool> asignarEntrenadorAEvento(int idUsuario, int idEvento) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/$idUsuario/asignar-evento/$idEvento'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error asignando entrenador: $e');
      return false;
    }
  }

  /// Modifica la asignación de un entrenador de un evento a otro.
  /// Retorna true si la operación fue exitosa (status 200).
  Future<bool> modificarAsignacionEntrenador({
    required int idUsuario,
    required int idEvento,
    required int nuevoIdEvento,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/$idUsuario/modificar-asignacion/$idEvento/a/$nuevoIdEvento'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error modificando asignación: $e');
      return false;
    }
  }
  
  Future<List<EventModel>> getEventosAsignados(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/usuarios/$idUsuario/eventos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Si usas autenticación con token:
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: No se pudieron obtener los eventos del servidor');
      }
    } catch (e) {
      // Aquí puedes loguear el error o reportarlo
      throw Exception('Fallo la conexión con el servidor: $e');
    }
  }


  /// -------------------------------------------------
  /// *MÉTODOS DE AUTENTICACIÓN DE USUARIOS
  /// -------------------------------------------------

  // Verificar si un correo ya existe
  Future<bool> existeCorreo(String email) async {
    try {
      final response = await http.get(Uri.parse('$apiUrlUsuarios?email=$email'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.isNotEmpty;
      }
    } catch (_) {
      return false; // ← más seguro para no bloquear
    }
    return false; // ← más seguro para no bloquear
  }

  String? ultimoToken;

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

      // Guarda el token en una propiedad accesible
      ultimoToken = token;

      return UserModel(
        id_usuario: decoded['id_usuario'],
        nombre: decoded['nombre'],
        email: email,
        contrasena: '',
        rol: decoded['rol'],
        estado_monitor: decoded['estado_monitor'],
      );
    }

    return null;
  }


  /*Future<UserModel?> authUsuarioRemoto(String email, String password) async {
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
        await prefs.setString('estado_monitor', decoded['estado_monitor']);

        return UserModel(
          id_usuario: decoded['id_usuario'],
          nombre: decoded['nombre'],
          email: email,
          contrasena: '', // no se guarda
          rol: decoded['rol'],
          estado_monitor: decoded['estado_monitor'],
        );
      }

      return null;
    } */

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

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LOS FORMULARIOS
  /// -------------------------------------------------

  Future<bool> sendFormularioRespondido(FormModel formulario, List<AnswerModel> respuestas) async {
    final body = {
      //'formulario': formulario.toJson(),
      'id_formulario' : formulario.id_formulario,
      'id_evento': formulario.id_evento,
      'respuestas': respuestas.map((r) => r.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/formularios/responder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }  

  Future<bool> sendEvidence(FormModel formulario) async {
    final evidencia = {
      'latitud': formulario.latitud,
      'longitud': formulario.longitud,
      'path_imagen': formulario.path_imagen,
    };

    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/formularios/${formulario.id_formulario}/evidencia'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(evidencia),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

/// --------------------------------------------------------

  /// --- MÉTODOS DE SINCRONIZACIÓN ---

  /// Sincroniza usuarios remotos con la base de datos local (descarga remota → inserta local)
  Future<void> sincronizarDesdeServidor() async {
    final usuariosRemotos = await fetchUsuarios();
    for (var user in usuariosRemotos) {
      final existe = await LocalDataService.db.existeCorreo(user.email);
      if (!existe) {
        await LocalDataService.db.insertUser(user);
      } else {
        await LocalDataService.db.updateUsuario(user);
      }
    }
  }

  /// Sincroniza usuarios locales con el servidor (local → remoto)
  /// útil para cuando hay conexión intermitente y se insertan datos offline
  Future<void> sincronizarHaciaServidor() async {
    final usuariosLocales = await LocalDataService.db.getNoSyncUsers(); // ✅ Solo los no sincronizados
    for (var user in usuariosLocales) {
      final correoExiste = await existeCorreo(user.email);
      if (!correoExiste) {
        final ok = await sendUsuario(user);
        if (ok) {
          await LocalDataService.db.markUserSync(user.id_usuario!);
        }
      }
    }
  }

  /// Sincroniza en ambos sentidos: primero descarga y luego sube
  Future<void> sincronizarTodo() async {
    await sincronizarDesdeServidor();
    await sincronizarHaciaServidor();
  }


}