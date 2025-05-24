import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/services/local_data_service.dart';
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

  /// Envía un evento al backend mediante una solicitud POST al endpoint `/eventos`.
  /// Retorna `true` si el evento fue creado exitosamente (códigos 201 o 200),
  /// de lo contrario retorna `false`.
  Future<bool> sendEvent(EventModel event) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/eventos'), // Asegúrate que apiUrl no termine con "/"
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Evento creado exitosamente.');
        return true;
      } else {
        print('Error al crear evento: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al enviar evento: $e');
      return false;
    }
  }

  /*Future<bool> sendEvent(EventModel event) async {
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
  }*/

  /// Obtiene todos los eventos desde el servidor mediante HTTP GET.
  ///
  
  Future<List<EventModel>> fetchEventos() async {
    try {
      final uri = Uri.parse('$apiUrl/eventos'); // asegurarse de la URl
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

  /// Actualiza parcialmente un evento en el backend mediante una solicitud PATCH al endpoint `/eventos/{id}`.
  /// Retorna `true` si la actualización fue exitosa (código 200), de lo contrario `false`.
  Future<bool> updateEventoParcial(int idEvento, EventModel eventoParcial) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/eventos/$idEvento'), // URL con el id del evento
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(eventoParcial.toJson()), // El JSON con los campos a actualizar
      );

      if (response.statusCode == 200) {
        print('Evento actualizado exitosamente.');
        return true;
      } else {
        print('Error al actualizar evento: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al actualizar evento: $e');
      return false;
    }
  }

  /*Future<bool> updateEvento(EventModel evento) async {
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
  }*/

  /// Desactiva (deshabilita) un evento haciendo una solicitud DELETE.
  ///
  Future<bool> desactivarEvento(int idEvento) async {
    final url = Uri.parse('$apiUrl/eventos/$idEvento');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Si necesitas token:
          // 'Authorization': 'Bearer tu_token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result == true; // Retorna true si el backend lo devuelve así
      } else {
        print('Error al desactivar el evento: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Excepción al desactivar el evento: $e');
      return false;
    }
  }
  /*Future<bool> deshabilitarEvento(int idEvento) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$idEvento'),
        headers: {'Content-Type': 'application/json'},
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

  /// Deshabilita un entrenador dado su ID.
  Future<bool> deshabilitarEntrenador(int idUsuario) async {
    final url = Uri.parse('$apiUrlUsuarios/$idUsuario/deshabilitar');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN', // si se esta usando
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al deshabilitar entrenador: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al deshabilitar entrenador: $e');
      return false;
    }
  }

  /// -------------------------------------------------
  /// *MÉTODOS DE ASIGNACIONES
  /// -------------------------------------------------
  /// 
  
  /// Asigna un entrenador a un evento mediante una solicitud HTTP.
  Future<bool> asignarEntrenadorAEvento(int idUsuario, int idEvento) async {
    final url = Uri.parse('http://<TU_BACKEND>/usuarios/$idUsuario/asignar-evento/$idEvento');
    try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Si estás usando JWT u otro token:
        // 'Authorization': 'Bearer <token>',
      },
    );

    if (response.statusCode == 200) {
      print('✅ ${response.body}');
      return true;
    } else {
      print('❌ Error al asignar entrenador: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Excepción: $e');
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

    // Enviar POST al backend para invalidar la sesión (HttpSession)
    await http.post(
      Uri.parse('https://tu-api.com/logout'),
      // IMPORTANTE: no se agregan headers personalizados
    );

    // Limpiar datos locales
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