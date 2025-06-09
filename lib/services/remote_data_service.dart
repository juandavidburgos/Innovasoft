import 'package:basic_flutter/models/question_model.dart';

import '../models/form_model.dart';
import '../models/DTO/FormularioDTOPeticion.dart';
import 'package:basic_flutter/services/local_data_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/answer_model.dart';
import '../models/event_assignment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Para descargar el reporte
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RemoteDataService {

  /// -------------------------------------------------
  /// *MÉTODOS REMOTOS
  /// -------------------------------------------------

  // Url del api
  final String apiUrl = 'http://10.0.2.2:8080/api';
  final String apiUrlUsuarios = 'http://10.0.2.2:8080/api';

  static final RemoteDataService dbR = RemoteDataService();

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A EVENTOS
  /// -------------------------------------------------

  /// Envía un evento al backend mediante una solicitud POST al endpoint `/eventos`.
  /// Retorna `true` si el evento fue creado exitosamente (códigos 201 o 200),
  /// de lo contrario retorna `false`.
  Future<bool> sendEvent(EventModel event) async {
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/eventos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← AQUI VA EL TOKEN
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
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/eventos/$idEvento'), // URL con el id del evento
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← AQUI VA EL TOKEN
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

  /// Desactiva (deshabilita) un evento haciendo una solicitud DELETE.
  ///
  Future<bool> desactivarEvento(int idEvento) async {
    final url = Uri.parse('$apiUrl/eventos/$idEvento');
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← AQUI VA EL TOKEN
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
        Uri.parse('$apiUrlUsuarios/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<UserModel?> sendUsuarioYRecibir(UserModel usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrlUsuarios/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );
      print('📥 Respuesta del backend: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Usuario registrado: $data');
        return UserModel.fromJson(data);
      }
    } catch (e) {
      print("❌ Error al enviar usuario: $e");
    }
    
    return null;
  }



  // Obtener todos los Monitores desde el servidor
  Future<List<UserModel>> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/monitores'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener los monitores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  /*Future<List<UserModel>> fetchUsuarios() async {
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
  }*/

  // Actualizar un usuario existente
  Future<bool> updateUsuario(UserModel usuario) async {
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado
    try {
      final response = await http.put(
        Uri.parse('$apiUrlUsuarios/${usuario.id_usuario}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // si se esta usando
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
    final url = Uri.parse('$apiUrlUsuarios/$idUsuario/asignar-evento/$idEvento');
    final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado
    try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Si estás usando JWT u otro token:
        'Authorization': 'Bearer $token',
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
Future<bool> modificarAsignacionEntrenador({required int idUsuario, required int idEvento, required int nuevoIdEvento}) async {
  final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado
  try {
    final response = await http.patch(
      Uri.parse('$apiUrl/$idUsuario/modificar-asignacion/$idEvento/a/$nuevoIdEvento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );
    return response.statusCode == 200;
  } catch (e) {
    print('Error modificando asignación: $e');
    return false;
  }
}

//obtener las asignaciones de los eventos
  Future<List<EventoAsignacionModel>> fetchAsignacionesPorEvento() async {
    final url = Uri.parse('$apiUrl/asignaciones');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => EventoAsignacionModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener las asignaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  
Future<List<EventModel>> getEventosAsignados(int idUsuario) async {
  final token = RemoteDataService.dbR.ultimoToken; // Asegúrate de que esté guardado
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/monitor/$idUsuario/activos'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Si usas autenticación con token:
        'Authorization': 'Bearer $token',
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
    final url = Uri.parse('http://10.0.2.2:8080/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'contrasena': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final decoded = json.decode(token);

      // Guarda el token para usarlo después
      ultimoToken = token;

      return UserModel(
        id_usuario: decoded['id_usuario'],
        nombre: decoded['nombre'],
        email: decoded['email'],
        contrasena: '',
        rol: decoded['rol'],
        estado_monitor: decoded['estado_monitor'],
      );
    } else {
      // Manejar errores
      String mensaje = 'Error de autenticación';
      try {
        final cuerpo = jsonDecode(response.body);
        if (cuerpo is String) {
          mensaje = cuerpo;
        } else if (cuerpo is Map && cuerpo.containsKey('mensaje')) {
          mensaje = cuerpo['mensaje'];
        }
      } catch (_) {
        mensaje = response.body;
      }

      throw Exception(mensaje);
    }
  }



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
  
  Future<bool> enviarRespuestasFormulario(int idFormulario, int idEvento, List<AnswerModel> respuestas) async {
    final body = {
      'idFormulario': idFormulario,
      'idEvento': idEvento,
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


  Future<FormularioDTOPeticion?> crearFormularioEnBackend(FormularioDTOPeticion form) async {
    final token = RemoteDataService.dbR.ultimoToken;
    print("🛡️ TOKEN: $token");

    final response = await http.post(
        Uri.parse('$apiUrl/formularios'),
        headers: {
          'Content-Type': 'application/json',
          // Si usas autenticación JWT:
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(form.toJson()), // debes tener un método toJson() en tu modelo
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return FormularioDTOPeticion.fromJson(data); 
      } else {
        print('❌ Error al crear formulario: ${response.body}');
        return null;
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
          print("SINCRONIZACION EXITOSA");
        }else{
          print("NO SE PUDO SINCRONIZAR");
        }
      }
    }
  }

  /// Sincroniza en ambos sentidos: primero descarga y luego sube
  Future<void> sincronizarTodo() async {
    await sincronizarDesdeServidor();
    await sincronizarHaciaServidor();
  }

  Future<void> sincronizarFormulariosYPreguntasDesdeServidor() async {
    final response = await http.get(Uri.parse('$apiUrl/formularios/preguntas'));

    if (response.statusCode == 200) {
      final formulariosJson = jsonDecode(response.body) as List;

      print('📦 JSON recibido del backend:');
      print(jsonEncode(formulariosJson));


      for (var formJson in formulariosJson) {

        // ✅ Validación necesaria
        if (formJson['id_evento'] == null || formJson['id_usuario'] == null) {
          print("⚠️ Formulario omitido: ${formJson['titulo']} → evento: ${formJson['evento_id']}, usuario: ${formJson['id_usuario']}");
          continue;
        }


        final form = FormModel(
          id_formulario: formJson['id_formulario'], // opcional si la tabla usa ID local
          titulo: formJson['titulo'],
          descripcion: formJson['descripcion'],
          fecha_creacion: DateTime.parse(formJson['fecha_creacion']),
          id_evento: formJson['id_evento'],
          id_usuario: formJson['id_usuario'],
          latitud: null,
          longitud: null,
          path_imagen: null,
        );
        print('📝 Insertando formulario: ${form.titulo} - evento: ${form.id_evento}, usuario: ${form.id_usuario}');
        final idFormLocal = await LocalDataService.db.insertForm(form); // o formJson['id_formulario'] si lo usas directamente
      

        final preguntas = formJson['preguntas'] as List;
        for (var pregJson in preguntas) {
          final pregunta = QuestionModel(
            id_pregunta: pregJson['id_pregunta'],
            formulario_id: idFormLocal,
            contenido: pregJson['contenido_pregunta'],
            tipo: pregJson['tipo_pregunta'],
            obligatoria: pregJson['obligatorio'] == 1, // ← aquí está la solución
          );

          print('📝 Insertando pregunta ID: ${pregunta.id_pregunta} - Formulario: ${pregunta.formulario_id}');
          await LocalDataService.db.insertPregunta(pregunta);
        }

      }

      print('✅ Sincronización completa de formularios y preguntas');
    } else {
      print('❌ Error al sincronizar formularios: ${response.body}');
      throw Exception('Fallo la sincronización');
    }
  }



  /// -------------------------------------------------
  /// *MÉTODO ASOCIADOS A LA GENERACION DEL REPORTE
  /// -------------------------------------------------
  
Future<File?> descargarReporteExcel(int idEvento) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/excel/$idEvento'),
        headers: {
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          // Si manejas autenticación, agrega también el token aquí
          //'Authorization': 'Bearer tu_token'
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/Reporte_Evento_$idEvento.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        return file; // Lo puedes abrir o mostrar en el UI
      } else {
        print('Error al descargar el reporte: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en la descarga del reporte: $e');
      return null;
    }
  }

}