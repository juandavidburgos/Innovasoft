import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/services/remote_data_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event_model.dart'; 
import 'dart:async';
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
class LocalDataService {

  /// -------------------------------
  /// *CREACIÓN DE LA BASE DE DATOS
  /// -------------------------------

  static Database? _db;
  static final LocalDataService db = LocalDataService._();

  //Creación de tablas

  static const String tableEventos = 'eventos';
  static const String tableUsuarios = 'usuarios';
  static const String tableAsignaciones = 'asignaciones';
  static const String tableFormularios = 'formularios';
  static const String tablePreguntas = 'preguntas';
  static const String tableRespuestas = 'respuestas';

  //Instancia del servicio
  LocalDataService._();

  //Inicializar base de datos
  Future<Database> _initDB() async {
    try {
      final path = join(await getDatabasesPath(), 'app.db');

      //Mostrar la ruta en consola
      //print('Ruta de la base de datos: $path');

      //await deleteDB();

      return await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          // Crear tabla eventos
          await db.execute('''
            CREATE TABLE $tableEventos (
              id_evento INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              fecha_hora_inicio TEXT NOT NULL,
              fecha_hora_fin TEXT NOT NULL,
              ubicacion TEXT NOT NULL,
              descripcion TEXT,  -- Nueva columna para la descripción del evento
              estado TEXT CHECK(estado IN ('activo', 'inactivo')) DEFAULT 'activo'
            );
          ''');

          // Crear tabla usuarios
          await db.execute('''
            CREATE TABLE $tableUsuarios (
            id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            contrasena TEXT NOT NULL,
            rol TEXT CHECK(rol IN ('Monitor', 'Administrador')) NOT NULL,
            estado_monitor TEXT CHECK(estado_monitor IN ('activo', 'inactivo')) DEFAULT 'activo',
            sincronizado INTEGER NOT NULL DEFAULT 0
          );
          ''');

          // Crear tabla asignaciones (relación muchos a muchos entre eventos y entrenadores)
          await db.execute('''
            CREATE TABLE $tableAsignaciones (
              id_asignacion  INTEGER PRIMARY KEY AUTOINCREMENT,
              id_evento INTEGER NOT NULL,
              id_usuario INTEGER NOT NULL,
              FOREIGN KEY (id_evento) REFERENCES $tableEventos(id_evento),
              FOREIGN KEY (id_usuario) REFERENCES $tableUsuarios(id_usuario),
              UNIQUE(id_evento, id_usuario) -- Evita duplicados
            );
          ''');

          // Crear tabla formularios
          await db.execute('''
            CREATE TABLE $tableFormularios (
              id_formulario INTEGER PRIMARY KEY AUTOINCREMENT,
              titulo TEXT NOT NULL,
              descripcion TEXT,
              fecha_creacion TEXT NOT NULL,
              id_evento INTEGER NOT NULL,
              id_usuario INTEGER NOT NULL,
              latitud REAL,
              longitud REAL,
              path_imagen TEXT,
              FOREIGN KEY (id_evento) REFERENCES eventos(id_evento),
              FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
            );
          ''');

          // Crear tabla preguntas
          await db.execute('''
            CREATE TABLE $tablePreguntas(
              id_pregunta INTEGER PRIMARY KEY AUTOINCREMENT,
              formulario_id INTEGER NOT NULL,
              contenido TEXT NOT NULL,
              tipo TEXT CHECK(tipo IN ('Texto', 'Número', 'Opción', 'Fecha', 'Si/No')) NOT NULL,
              es_obligatoria INTEGER CHECK(es_obligatoria IN (0, 1)) DEFAULT 1,
              FOREIGN KEY (formulario_id) REFERENCES formularios(id_formulario)
            );
          ''');

          // Crear tabla respuestas
          await db.execute(''' 
            CREATE TABLE $tableRespuestas (
              id_respuesta INTEGER PRIMARY KEY AUTOINCREMENT,
              pregunta_id INTEGER NOT NULL,
              formulario_id INTEGER NOT NULL,
              contenido TEXT NOT NULL,
              FOREIGN KEY (pregunta_id) REFERENCES preguntas(id_pregunta),
              FOREIGN KEY (formulario_id) REFERENCES formularios(id_formulario)
            );
          ''');

          //Crear Tabla para la cola de peticiones
          await db.execute('''
            CREATE TABLE cola_peticiones (
              id_local INTEGER PRIMARY KEY AUTOINCREMENT,
              payload TEXT NOT NULL, -- JSON que contiene formulario + respuestas
              fecha_guardado TEXT NOT NULL
            );
          ''');

        },
      );
    } catch (e) {
      throw Exception('Error al inicializar la base de datos: $e');
    }
  }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A LA BASE DE DATOS
  /// -----------------------------------------


  Future<void> deleteDB() async {
    try {
      // Obtén la ruta de la base de datos
      final path = join(await getDatabasesPath(), 'app.db');
      
      // Elimina la base de datos
      await deleteDatabase(path); //--->REALMENTER ESTA LINEA ELIMINA LA BASE DE DATOS

      print("Base de datos eliminada con éxito.");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }

  Future<Database> get database async {
      _db ??= await _initDB();
      return _db!;
    }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A EVENTOS
  /// -----------------------------------------
  
  Future<int> insertEvento(EventModel evento) async {
  final db = await database;

    return await db.insert(
      tableEventos,
      {
        'nombre': evento.nombre,
        'fecha_hora_inicio': evento.fecha_hora_inicio.toIso8601String(),
        'fecha_hora_fin': evento.fecha_hora_fin.toIso8601String(),
        'ubicacion': evento.ubicacion,
        'descripcion': evento.descripcion,
        //'id_usuario': evento.idUsuario, // si no lo usas por ahora
        'estado': 'activo', // por defecto
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// Obtiene todos los eventos desde la base de datos.
  /// 
  /// Si [soloActivos] es `true`, filtra los eventos con estado 'activo'.
  /// Retorna una lista de objetos `EventModel`.
  Future<List<EventModel>> getEventos({bool soloActivos = false}) async {
    final db = await database;

    // Realizar consulta con filtro si se requiere solo eventos activos
    final List<Map<String, dynamic>> maps = await db.query(
      tableEventos,
      where: soloActivos ? 'estado = ?' : null, // Filtrar por estado si soloActivos es true
      whereArgs: soloActivos ? ['activo'] : null, // Definir el argumento 'activo' para el filtro
    );

    // Convertir los registros obtenidos en una lista de objetos EventModel
    return List.generate(maps.length, (i) {
      DateTime? fechaHoraInicio;
      DateTime? fechaHoraFin;
      try {
        // Intentar parsear la fecha en formato ISO 8601
        fechaHoraInicio = DateTime.parse(maps[i]['fecha_hora_inicio']);
        fechaHoraFin = DateTime.parse(maps[i]['fecha_hora_fin']);
      } catch (e) {
        try {
          // Si falla el parseo ISO 8601, intenta con un formato diferente
          final DateFormat format = DateFormat('dd-MM-yyyy HH:mm');
          fechaHoraInicio  = format.parse(maps[i]['fecha_hora_inicio']);
          fechaHoraFin = format.parse(maps[i]['fecha_hora_fin']);
        } catch (e) {
          // Si ambos intentos fallan, asigna una fecha por defecto o maneja el error de alguna manera
          fechaHoraInicio = DateTime.now();
          fechaHoraFin = DateTime.now();  //lanzar una excepción
        }
      }

      return EventModel(
        id_evento: maps[i]['id_evento'],
        nombre: maps[i]['nombre'],
        fecha_hora_inicio: fechaHoraInicio,
        fecha_hora_fin: fechaHoraFin,
        ubicacion: maps[i]['ubicacion'],
        descripcion: maps[i]['descripcion'] ?? '',
        id_usuario: maps[i]['id_usuario'],
        estado: maps[i]['estado'],
      );
    });
  }

  /// Actualiza un evento existente en la base de datos.
  /// 
  /// [evento] debe tener un `idEvento` válido.
  /// 
  /// Retorna el número de filas afectadas.
  Future<int> updateEvento(EventModel evento) async {
    final db = await database;
    return await db.update(
      tableEventos,
      evento.toMap(),
      where: 'id_evento = ?',
      whereArgs: [evento.id_evento],
    );
  }

  /// Marca un evento como 'inactivo' sin eliminarlo físicamente.
  /// 
  /// [id] es el ID del evento a deshabilitar.
  /// 
  /// Retorna el número de filas afectadas.
  Future<int> deshabilitarEvento(int id) async {
    final db = await database;
    return await db.update(
      tableEventos,
      {'estado': 'inactivo'},
      where: 'id_evento = ?',
      whereArgs: [id],
    );
  }

  /// Elimina permanentemente un evento de la base de datos.
  /// 
  /// [id] es el ID del evento a eliminar.
  /// 
  /// Retorna el número de filas eliminadas.
  Future<int> deleteEvento(int id) async {
    final db = await database;
    return await db.delete(tableEventos, where: 'id_evento = ?', whereArgs: [id]);
  }

  Future<void> deleteAllEvents() async {
  final db = await database;
  await db.delete(tableEventos); // nombre de la tabla
  }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A LOS USUARIOS
  /// -----------------------------------------

  /// Inserta un nuevo usuario en la base de datos.
  /// 
  /// [usuario] es una instancia de `UserModel` que se convierte a un mapa.
  /// 
  /// Retorna el ID del usuario insertado.
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      tableUsuarios,
      {
        'nombre': user.nombre,
        'email': user.email,
        'contrasena': user.contrasena,
        'rol': user.rol,
        'estado_monitor':user.estado_monitor,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todos los usuarios desde la base de datos.
  /// 
  /// Retorna una lista de objetos `UserModel`.
  Future<List<UserModel>> getUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableUsuarios);

    return List.generate(maps.length, (i) {
      return UserModel(
        id_usuario: maps[i]['id_usuario'],
        nombre: maps[i]['nombre'],
        email: maps[i]['email'],
        contrasena: maps[i]['contrasena'],
        rol: maps[i]['rol'],
        estado_monitor: maps[i]['estado_monitor'],
      );
    });
  }

  /// Actualiza un usuario existente en la base de datos.
  /// 
  /// [usuario] debe tener un `idUsuario` válido.
  /// 
  /// Retorna el número de filas afectadas.
  Future<int> updateUsuario(UserModel usuario) async {
    final db = await database;
    return await db.update(
      tableUsuarios,
      usuario.toMap(),
      where: 'id_usuario = ?',
      whereArgs: [usuario.id_usuario],
    );
  }

  /// Elimina permanentemente un usuario de la base de datos.
  /// 
  /// [id] es el ID del usuario a eliminar.
  /// 
  /// Retorna el número de filas eliminadas.
  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete(
      tableUsuarios,
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserModel>> getNoSyncUsers() async {
    final db = await database;
    final maps = await db.query('usuarios', where: 'sincronizado = ?', whereArgs: [0]);

    return maps.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> markUserSync(int idUsuario) async {
    final db = await database;
    await db.update(
      'usuarios', 
      {'sincronizado': 1}, 
      where: 'id_usuario = ?', 
      whereArgs: [idUsuario],
      );
  }


  ///Deshabilitar entrenadores
  ///Cambia su estado a "INACTIVO" 
  
  Future<int> disableUser(int id) async {
    final db = await database;
    return await db.update(
      tableUsuarios,
      {'estado_monitor': 'inactivo'},
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
  }

  //Usuarios entrenadres:

  Future<List<UserModel>> getEntrenadores() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableUsuarios,
      where: 'rol = ?',
      whereArgs: ['Monitor'],
    );

    return List.generate(maps.length, (i) {
      return UserModel(
        id_usuario: maps[i]['id_usuario'],
        nombre: maps[i]['nombre'],
        email: maps[i]['email'],
        contrasena: maps[i]['contrasena'],
        rol: maps[i]['rol'],
        estado_monitor: maps[i]['estado_monitor'],
      );
    });
  }

  Future<List<UserModel>> getEntrenadoresActivos() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableUsuarios,
      where: 'rol = ? AND estado_monitor = ?',
      whereArgs: ['Monitor', 'activo'],
    );

    return List.generate(maps.length, (i) {
      return UserModel(
        id_usuario: maps[i]['id_usuario'],
        nombre: maps[i]['nombre'],
        email: maps[i]['email'],
        contrasena: maps[i]['contrasena'],
        rol: maps[i]['rol'],
        estado_monitor: maps[i]['estado_monitor'],
      );
    });
  }

  //Autenticación de usuarios:

  /// Valida si un correo electrónico ya existe en la base de datos.
  /// 
  /// [email] es el correo electrónico que queremos verificar.
  /// 
  /// Retorna `true` si el correo ya existe, de lo contrario `false`.
  Future<bool> existeCorreo(String email) async {
    final db = await database;

    // Realizamos una consulta para verificar si el correo existe en la tabla
    final result = await db.query(
      tableUsuarios,
      where: 'email = ?',
      whereArgs: [email],
    );

    // Si el resultado tiene algún elemento, significa que el correo ya está registrado
    return result.isNotEmpty;
  }

  Future<bool> existeUsuarioPorCorreo(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A LAS ASIGNACIONES
  /// -----------------------------------------
  
  /// Asigna uno o más entrenadores a un evento insertando registros en la tabla `asignaciones`.
  ///
  /// [eventoId] es el ID del evento.
  /// [trainerIds] es una lista de IDs de entrenadores a asignar.
  /// 
  /// Retorna el número de asignaciones insertadas correctamente.
  Future<int> assignTrainers(int eventoId, List<int> trainerIds) async {
    final db = await database;
    int count = 0;

    for (int trainerId in trainerIds) {
      try {
        await db.insert(
          tableAsignaciones,
          {
            'id_evento': eventoId,
            'id_usuario': trainerId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore, // Ignora si ya existe
        );
        count++;
      } catch (e) {
        // Si hay un error (como violación UNIQUE), lo ignoramos aquí
        // Registro del error para depuración
        print("Error al asignar entrenador (ID: $trainerId) a evento (ID: $eventoId): $e");
        }
    }

    return count;
  }

/// Obtiene el evento asignado a un usuario (entrenador), usando relación muchos a muchos.
/// Usa consulta SQL segura con parámetros para prevenir inyección.
  Future<List<Map<String, dynamic>>> obtenerEventosAsignadosPorUsuario(int idUsuario) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT e.* 
      FROM $tableEventos e
      INNER JOIN $tableAsignaciones a ON e.id_evento = a.id_evento
      WHERE a.id_usuario = ? AND e.estado = 'activo';
      ''',
      [idUsuario],
    );

    return result;
  }


  /// Obtiene todos los eventos que tienen al menos un entrenador asignado.
  /// 
  /// Retorna una lista de [EventModel] y el nombre de los entrenadores.
  Future<List<Map<String, dynamic>>> getAssignedEvents() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        e.*, 
        GROUP_CONCAT(u.nombre, ', ') AS entrenadores
      FROM $tableEventos e
      INNER JOIN $tableAsignaciones a ON e.id_evento = a.id_evento
      INNER JOIN $tableUsuarios u ON a.id_usuario = u.id_usuario
      GROUP BY e.id_evento
    ''');

    return result.map((map) {
      DateTime? fechaHoraInicio;
      DateTime? fechaHoraFin;

      final rawInicio = map['fecha_hora_inicio'];
      final rawFin = map['fecha_hora_fin'];

      try {
        fechaHoraInicio = DateTime.parse(rawInicio.toString());
        fechaHoraFin = DateTime.parse(rawFin.toString());
      } catch (_) {
        try {
          final format = DateFormat('dd-MM-yyyy HH:mm');
          fechaHoraInicio = format.parse(rawInicio.toString());
          fechaHoraFin = format.parse(rawFin.toString());
        } catch (_) {
          fechaHoraInicio = DateTime.now();
          fechaHoraFin = DateTime.now().add(Duration(hours: 1));
        }
      }

      return {
        'evento': EventModel(
          id_evento: int.tryParse(map['id_evento']?.toString() ?? ''), // Usamos tryParse para convertir
          nombre: map['nombre']?.toString() ?? '', // Convertimos a String
          descripcion: map['descripcion']?.toString() ?? '', // Convertimos a String
          ubicacion: map['ubicacion']?.toString() ?? '', // Convertimos a String
          fecha_hora_inicio: fechaHoraInicio,
          fecha_hora_fin: fechaHoraFin,
          estado: map['estado']?.toString() ?? '', // Convertimos a String
        ),
        'entrenadores': map['entrenadores'], // String con los nombres
      };
    }).toList();
  }

  /// Actualiza las asignaciones de entrenadores para un evento.
  /// Primero elimina las asignaciones existentes y luego inserta las nuevas.
  ///
  /// [eventoId] es el ID del evento.
  /// [trainerIds] es la nueva lista de IDs de entrenadores.
  ///
  /// Retorna `true` si la operación fue exitosa, `false` si falló.
  Future<bool> updateEventAssignments(int eventoId, List<int> trainerIds) async {
    final db = await database;

    try {
      // Iniciar una transacción para mantener la integridad
      await db.transaction((txn) async {
        // Eliminar asignaciones existentes para el evento
        await txn.delete(
          tableAsignaciones,
          where: 'id_evento = ?',
          whereArgs: [eventoId],
        );

        // Insertar las nuevas asignaciones
        for (int trainerId in trainerIds) {
          await txn.insert(
            tableAsignaciones,
            {
              'id_evento': eventoId,
              'id_usuario': trainerId,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });

      return true;
    } catch (e) {
      print('Error al actualizar asignaciones del evento $eventoId: $e');
      return false;
    }
  }

  /// Obtiene la lista de asignaciones con el nombre del evento.
  /// 
  /// Retorna una lista de mapas con `id_evento` y `nombre_evento`.
  Future<List<Map<String, dynamic>>> getAsignacionesConNombreEvento() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT DISTINCT e.id_evento, e.nombre
      FROM $tableAsignaciones a
      INNER JOIN $tableEventos e ON a.id_evento = e.id_evento
      WHERE e.estado = 'activo'
      ORDER BY e.nombre
    ''');

    return result;
  }

  /// Obtiene los entrenadores asignados a un evento específico.
  /// 
  /// [eventoId] es el ID del evento seleccionado.
  ///
  /// Retorna una lista de mapas con los datos de los entrenadores.
  Future<List<Map<String, dynamic>>> getTrainersByEvento(int eventoId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT u.id_usuario, u.nombre
      FROM $tableAsignaciones a
      INNER JOIN $tableUsuarios u ON a.id_usuario = u.id_usuario
      WHERE a.id_evento = ?
    ''', [eventoId]);

    return result;
  }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A LOS FORMULARIOS
  /// -----------------------------------------

  //Insertar formulario
  Future<void> insertForm(FormModel formulario) async {
    final db = await database;
    await db.insert(
      tableFormularios,
      {
        'id_formulario': formulario.id_formulario,
        'titulo': formulario.titulo,
        'descripcion': formulario.descripcion,
        'fecha_creacion': formulario.fecha_creacion.toIso8601String(),
        'id_evento': formulario.id_evento,
        'id_usuario': formulario.id_usuario,
        'latitud': formulario.latitud,
        'longitud': formulario.longitud,
        'path_imagen': formulario.path_imagen
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FormModel>> getForms() async {
    final db = await database;
    final result = await db.query(tableFormularios);

    return result.map((json) => FormModel(
      id_formulario: json['idFormulario'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fecha_creacion: DateTime.parse(json['fechaCreacion'] as String),
      id_evento: json['id_evento'] as int,
      id_usuario: json['usuarioId'] as int,
      latitud: json['latitud'] as double?,
      longitud: json['longitud'] as double?,
      path_imagen: json['pathImagen'] as String?,
    )).toList();
  }

// NO SE A PROBADO
  Future<List<FormModel>> getFormsByEvent(int eventoId) async {
    final db = await database;
    final result = await db.query(
      tableFormularios,
      where: 'evento_id = ?',
      whereArgs: [eventoId],
    );

    return result.map((json) => FormModel(
      id_formulario: json['id_formulario'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fecha_creacion: DateTime.parse(json['fecha_creacion'] as String),
      id_evento: json['id_evento'] as int,
      id_usuario: json['id_usuario'] as int,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      path_imagen: json['path_imagen'] as String?,
    )).toList();
  }

///METODO SIN PROBAR
  Future<List<Map<String, dynamic>>> getAsistentesFormulario(
    int idUsuario, int idEvento) async {
    
    final db = await database;

    // Obtener los formularios del usuario en ese evento
    final formularios = await db.query(
      'formularios',
      where: 'evento_id = ? AND id_usuario = ?',
      whereArgs: [idEvento, idUsuario],
    );

    print('formularios: $formularios');

    List<Map<String, dynamic>> asistentes = [];

    for (var formulario in formularios) {
      final formularioId = formulario['id_formulario'];

      // Obtener preguntas relacionadas al formulario que tengan que ver con nombre, correo, o identificación
      final preguntas = await db.query(
        'preguntas',
        where: 'formulario_id = ? AND (LOWER(contenido) LIKE ? OR LOWER(contenido) LIKE ? OR LOWER(contenido) LIKE ?)',
        whereArgs: [
          formularioId,
          '%nombre%',
          '%correo%',
          '%identificación%',
        ],
      );

      for (var pregunta in preguntas) {
        final preguntaId = pregunta['id_pregunta'];
        final contenidoPregunta = pregunta['contenido'].toString().toLowerCase();

        // Obtener respuestas para esa pregunta
        final respuestas = await db.query(
          'respuestas',
          where: 'formulario_id = ? AND pregunta_id = ?',
          whereArgs: [formularioId, preguntaId],
        );

        for (var respuesta in respuestas) {
          final valor = respuesta['contenido'];

          // Buscamos si ya hay un asistente con ese formulario
          var asistente = asistentes.firstWhere(
              (a) => a['formulario_id'] == formularioId,
              orElse: () => {});

          if (asistente.isEmpty) {
            asistente = {
              'formulario_id': formularioId,
              'nombre': '',
              'correo': '',
              'identificacion': '',
            };
            asistentes.add(asistente);
          }

          // Asignamos según el tipo de pregunta
          if (contenidoPregunta.contains('nombre')) {
            asistente['nombre'] = valor;
          } else if (contenidoPregunta.contains('correo')) {
            asistente['correo'] = valor;
          } else if (contenidoPregunta.contains('identificación') ||
              contenidoPregunta.contains('identificacion')) {
            asistente['identificacion'] = valor;
          }
        }
      }
    }

    return asistentes;
  }

  /// -----------------------------------------
  /// *MÉTODOS ASOCIADOS A RESPUESTAS
  /// -----------------------------------------

  Future<void> insertAnswer(List<AnswerModel> respuestas) async {
    final db = await database;
    Batch batch = db.batch();
    for (var respuesta in respuestas) {
      batch.insert(
        tableRespuestas,
        {
          'id_respuesta': respuesta.id_respuesta,
          'pregunta_id': respuesta.pregunta_id,
          'contenido': respuesta.contenido,
          'formulario_id': respuesta.formulario_id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<AnswerModel>> getAnswers(int formularioId) async {
    final db = await database;
    final result = await db.query(
      tableRespuestas,
      where: 'formulario_id = ?',
      whereArgs: [formularioId],
    );

    return result.map((json) => AnswerModel(
      id_respuesta: json['id'] as int,
      pregunta_id: json['pregunta_id'] as int,
      contenido: json['contenido'] as String,
      formulario_id: json['formulario_id'] as int,
      id_evento: json['id_evento'] as int,
    )).toList();
  }


  Future<void> deleteFormAnswers(int formularioId) async {
    final db = await database;
    await db.delete(
      tableFormularios,
      where: 'id = ?',
      whereArgs: [formularioId],
    );
    await db.delete(
      tableRespuestas,
      where: 'formularioId = ?',
      whereArgs: [formularioId],
    );
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LA COLA DE PETICIONES
  /// -------------------------------------------------

  Future<void> guardarEnCola(FormModel formulario, List<AnswerModel> respuestas) async {
    final db = await database;

    final payload = jsonEncode({
      'formulario': formulario.toJson(),
      'respuestas': respuestas.map((r) => r.toJson()).toList(),
    });

    await db.insert('cola_peticiones', {
      'payload': payload,
      'fecha_guardado': DateTime.now().toIso8601String(),
    });
  }

  Future<void> procesarCola() async {
    final db = await database;

    final registros = await db.query('cola_peticiones');

    for (final reg in registros) {
      final idLocal = reg['id_local'] as int;
      final payload = jsonDecode(reg['payload'] as String);

      final form = FormModel.fromJson(payload['formulario']);
      final respuestas = (payload['respuestas'] as List)
          .map((r) => AnswerModel.fromJson(r))
          .toList();

      final exito = await RemoteDataService.dbR.sendFormularioRespondido(form, respuestas);
      if (exito) {
        await db.delete('cola_peticiones', where: 'id_local = ?', whereArgs: [idLocal]);
      }
    }
  }

  Future<void> guardarEvidenciaEnCola(FormModel formulario) async {
    final db = await database;

    final payload = jsonEncode({
      'formulario': formulario.toJson(), // sólo FormModel
    });

    await db.insert('cola_evidencias', {
      'payload': payload,
      'fecha_guardado': DateTime.now().toIso8601String(),
    });
  }


  Future<void> procesarColaEvidencias() async {
    final db = await database;

    final registros = await db.query('cola_evidencias');

    for (final reg in registros) {
      final idLocal = reg['id_local'] as int;
      final payload = jsonDecode(reg['payload'] as String);

      final form = FormModel.fromJson(payload['formulario']);

      final exito = await RemoteDataService.dbR.sendEvidence(form); // 👈 Tu método PATCH
      if (exito) {
        await db.delete('cola_evidencias', where: 'id_local = ?', whereArgs: [idLocal]);
      }
    }
  }

  Future<bool> hayFormulariosRegistrados() async {
    final db = await database;
    final enCola = await db.query('cola_peticiones');
    return enCola.isNotEmpty;
  }




  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LA AUTENTICACIÓN DE USUARIOS
  /// -------------------------------------------------

  Future<UserModel?> autenticarUsuario(String email, String password) async {
    final db = await database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND contrasena = ?', // <- ¡OJO aquí!
      whereArgs: [email, password],
    );

    if (resultado.isNotEmpty) {
      return UserModel.fromMap(resultado.first); // <- depende de tu implementación
    }
    return null;
  }

  Future<void> logOutLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_usuario');
    await prefs.remove('nombre_usuario');
    await prefs.remove('email_usuario');
    await prefs.remove('rol_usuario');
    // Nota: No hay jwt_token en sesiones locales
  }

    Future<int> crearAdminTemporal() async {
      final db = await database;

      return await db.insert(
        'usuarios',
        {
          'nombre': 'Juan Burgos',
          'email': 'admin@local.com',
          'contrasena': 'Admin123!', // contraseña temporal
          'rol': 'Administrador',
          'estado_monitor': 'ACTIVO',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // evita duplicados si ya existe
      );
  }

  /// -------------------------------------------------
  /// *MÉTODO PARA DETECTAR CONEXION
  /// -------------------------------------------------
  
  bool _procesandoColas = false;

  void iniciarEscuchaDeConexion() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none && !_procesandoColas) {
        _procesandoColas = true;

        try {
          await procesarCola();
          await procesarColaEvidencias();
          await RemoteDataService.dbR.sincronizarHaciaServidor();
        } catch (e, stackTrace) {
          // Loguear el error si algo falla (útil para debug o reporting)
          print('❌ Error durante sincronización: $e');
          print('🧵 StackTrace: $stackTrace');
        } finally {
          _procesandoColas = false;
        }
      }
    });
  }

  Future<bool> hayInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

}

