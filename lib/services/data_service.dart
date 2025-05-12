import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import '../models/formulario.dart';
//import '../models/respuesta.dart';
import '../models/event_model.dart'; // Importa tu modelo de eventos
import 'dart:async';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService db = DatabaseService._();

  static const String tableEventos = 'eventos';
  static const String tableUsuarios = 'usuarios';
  static const String tableAsignaciones = 'asignaciones';
  static const String tableFormularios = 'formularios';
  static const String tablePreguntas = 'preguntas';
  static const String tableRespuestas = 'respuestas';

  DatabaseService._();

  Future<void> deleteDB() async {
    try {
      // Obtén la ruta de la base de datos
      final path = join(await getDatabasesPath(), 'app.db');
      
      // Elimina la base de datos
      await deleteDatabase(path);

      print("Base de datos eliminada con éxito.");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }

Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    try {
      final path = join(await getDatabasesPath(), 'app.db');

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
            rol TEXT CHECK(rol IN ('ENTRENADOR', 'ADMINISTRADOR')) NOT NULL
          );
          ''');

          //Insertar usuarios iniciales
          await db.insert(tableUsuarios, {
            'nombre': 'Carlos Ramírez',
            'email': 'carlos@uni.edu',
            'contrasena': 'holis12wer33',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Laura Pérez',
            'email': 'laura@uni.edu',
            'contrasena': 'holis1wrewe233',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Matias Acosta',
            'email': 'matias@uni.edu',
            'contrasena': 'holis12wer33',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Henry Zapata',
            'email': 'henry@uni.edu',
            'contrasena': 'holis1wrewe233',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Lucas Araujo',
            'email': 'lucas@uni.edu',
            'contrasena': 'holis12wer33',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Maria Dolores',
            'email': 'maria@uni.edu',
            'contrasena': 'holis1wrewe233',
            'rol': 'ENTRENADOR',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Admin General',
            'email': 'admin@uni.edu',
            'contrasena': 'holisewrwe1233',
            'rol': 'ADMINISTRADOR',
          });

          // Crear tabla evento_entrenadores (relación muchos a muchos entre eventos y entrenadores)
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
              evento_id INTEGER NOT NULL,
              id_usuario INTEGER NOT NULL,
              latitud REAL,
              longitud REAL,
              path_imagen TEXT,
              FOREIGN KEY (evento_id) REFERENCES eventos(id_evento),
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
        },
      );
    } catch (e) {
      throw Exception('Error al inicializar la base de datos: $e');
    }
  }

  Future<int> insertEvento(EventModel evento) async {
  final db = await database;

    return await db.insert(
      tableEventos,
      {
        'nombre': evento.nombre,
        'fecha_hora_inicio': evento.fechaHoraInicio.toIso8601String(),
        'fecha_hora_fin': evento.fechaHoraFin.toIso8601String(),
        'ubicacion': evento.ubicacion,
        'descripcion': evento.descripcion,
        'id_usuario': null, // si no lo usas por ahora
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
        idEvento: maps[i]['id_evento'],
        nombre: maps[i]['nombre'],
        fechaHoraInicio: fechaHoraInicio,
        fechaHoraFin: fechaHoraFin,
        ubicacion: maps[i]['ubicacion'],
        descripcion: maps[i]['descripcion'] ?? '',
        idUsuario: maps[i]['id_usuario'],
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
      whereArgs: [evento.idEvento],
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

  //Metodos para usuario

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
        idUsuario: maps[i]['id_usuario'],
        nombre: maps[i]['nombre'],
        email: maps[i]['email'],
        contrasena: maps[i]['contrasena'],
        rol: maps[i]['rol'],
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
      whereArgs: [usuario.idUsuario],
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

  ///Metodos para asignacion
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

  /// Obtiene todos los eventos que tienen al menos un entrenador asignado.
  /// 
  /// Retorna una lista de [EventModel].
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
          idEvento: int.tryParse(map['id_evento']?.toString() ?? '') ?? null, // Usamos tryParse para convertir
          nombre: map['nombre']?.toString() ?? '', // Convertimos a String
          descripcion: map['descripcion']?.toString() ?? '', // Convertimos a String
          ubicacion: map['ubicacion']?.toString() ?? '', // Convertimos a String
          fechaHoraInicio: fechaHoraInicio!,
          fechaHoraFin: fechaHoraFin!,
          estado: map['estado']?.toString() ?? '', // Convertimos a String
        ),
        'entrenadores': map['entrenadores'], // String con los nombres
      };
    }).toList();
  }


  ///ES UNA OPCION
  /// Obtiene la lista de entrenadores asignados a un evento específico.
  ///
  /// [eventoId] es el ID del evento.
  /// Retorna una lista de mapas con los datos de los entrenadores.
  Future<List<Map<String, dynamic>>> getTrainersByEventId(int eventoId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT u.* FROM $tableUsuarios u
      INNER JOIN $tableAsignaciones a ON u.id_usuario = a.id_usuario
      WHERE a.id_evento = ?
    ''', [eventoId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllAssignments() async {
  final db = await database;
  return await db.query(tableAsignaciones);
  }

  /// Métodos para formularios
  //Insertar formulario
  Future<void> insertForm(FormModel formulario) async {
    final db = await database;
    await db.insert(
      tableFormularios,
      {
        'id': formulario.idFormulario,
        'titulo': formulario.titulo,
        'descripcion': formulario.descripcion,
        'fechaCreacion': formulario.fechaCreacion.toIso8601String(),
        'eventoId': formulario.eventoId,
        'usuarioId': formulario.usuarioId,
        'latitud': formulario.latitud,
        'longitud': formulario.longitud,
        'pathImagen': formulario.pathImagen,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAnswer(List<AnswerModel> respuestas) async {
    final db = await database;
    Batch batch = db.batch();
    for (var respuesta in respuestas) {
      batch.insert(
        tableRespuestas,
        {
          'id': respuesta.id,
          'preguntaId': respuesta.preguntaId,
          'contenido': respuesta.contenido,
          'formularioId': respuesta.formularioId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }


  Future<List<FormModel>> getForms() async {
    final db = await database;
    final result = await db.query(tableFormularios);

    return result.map((json) => FormModel(
      idFormulario: json['idFormulario'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      eventoId: json['eventoId'] as int,
      usuarioId: json['usuarioId'] as int,
      latitud: json['latitud'] as double?,
      longitud: json['longitud'] as double?,
      pathImagen: json['pathImagen'] as String?,
    )).toList();
  }


  Future<List<AnswerModel>> getAnswers(int formularioId) async {
    final db = await database;
    final result = await db.query(
      tableRespuestas,
      where: 'formularioId = ?',
      whereArgs: [formularioId],
    );

    return result.map((json) => AnswerModel(
      id: json['id'] as int,
      preguntaId: json['preguntaId'] as int,
      contenido: json['contenido'] as String,
      formularioId: json['formularioId'] as int,
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
}
/*
  // Métodos para eventos
  Future<int> insertEvento(EventModel evento) async {
    final db = await database;
    return await db.insert(
      tableEventos,
      {
        'nombre': evento.nombre,
        'fecha': evento.fecha.toIso8601String(),
        'ubicacion': evento.ubicacion,
        'id_usuario': evento.idUsuario,
        'estado': evento.estado,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EventModel>> getEventos({bool soloActivos = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableEventos,
      where: soloActivos ? 'estado = ?' : null,
      whereArgs: soloActivos ? ['activo'] : null,
    );

    return List.generate(maps.length, (i) {
      DateTime fecha = DateTime.tryParse(maps[i]['fecha']) ?? DateTime.now();
      return EventModel(
        idEvento: maps[i]['id_evento'],
        nombre: maps[i]['nombre'],
        fecha: fecha,
        ubicacion: maps[i]['ubicacion'],
        idUsuario: maps[i]['id_usuario'],
        estado: maps[i]['estado'],
      );
    });
  }
}*/
