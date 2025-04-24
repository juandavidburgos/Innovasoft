import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

/// Servicio local que gestiona operaciones CRUD con una base de datos SQLite.
/// Utiliza el paquete `sqflite` para almacenar eventos en el dispositivo.
class LocalService {
  /// Instancia privada de la base de datos.
  static Database? _db;

  /// Nombre de la tabla donde se almacenan los eventos.
  static const String tableEventos = 'eventos';
  /// Nombre de la tabla donde se almacenan los usuarios.
  static const String tableUsuarios = 'usuarios';

  /// Getter que retorna la instancia de la base de datos.
  /// Si aún no ha sido inicializada, llama a `initDB()`.
  Future<Database> get database async {
    _db ??= await initDB();
    return _db!;
  }

  /// Inicializa la base de datos SQLite.
  /// Crea la tabla `eventos` si aún no existe.
  /// 
  /// La tabla contiene los campos:
  /// - `id_evento`: clave primaria autoincremental.
  /// - `nombre`: nombre del evento.
  /// - `fecha`: fecha del evento.
  /// - `ubicacion`: ubicación del evento.
  /// - `id_usuario`: ID del usuario que creó el evento (opcional).
  /// - `estado`: 'activo' o 'inactivo' (valor por defecto: 'activo').
  Future<Database> initDB() async {
    try {
      final path = join(await getDatabasesPath(), 'eventos.db');

      return await openDatabase(
        path,
        version: 2, // Subimos la versión de la BD
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableEventos (
              id_evento INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              fecha TEXT NOT NULL,
              ubicacion TEXT NOT NULL,
              id_usuario INTEGER,
              estado TEXT CHECK(estado IN ('activo', 'inactivo')) DEFAULT 'activo'
            );
          ''');

          await db.execute('''
            CREATE TABLE $tableUsuarios (
              id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              rol TEXT CHECK(rol IN ('Monitor', 'Administrador')) NOT NULL
            );
          ''');

          // Insertar usuarios si es una nueva BD (onCreate)
          await db.insert(tableUsuarios, {
            'nombre': 'Carlos Ramírez',
            'email': 'carlos@uni.edu',
            'rol': 'Monitor',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Laura Pérez',
            'email': 'laura@uni.edu',
            'rol': 'Monitor',
          });
          await db.insert(tableUsuarios, {
            'nombre': 'Admin General',
            'email': 'admin@uni.edu',
            'rol': 'Administrador',
          });
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE $tableUsuarios (
                id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                rol TEXT CHECK(rol IN ('Monitor', 'Administrador')) NOT NULL
              );
            ''');

            // Insertar usuarios si se actualiza desde una BD antigua
            await db.insert(tableUsuarios, {
              'nombre': 'Carlos Ramírez',
              'email': 'carlos@indc.gov',
              'rol': 'Monitor',
            });
            await db.insert(tableUsuarios, {
              'nombre': 'Laura Pérez',
              'email': 'laura@indc.gov',
              'rol': 'Monitor',
            });
            await db.insert(tableUsuarios, {
              'nombre': 'Admin General',
              'email': 'admin@indc.gov',
              'rol': 'Administrador',
            });
          }
        },
      );
    } catch (e) {
      throw Exception('Error al inicializar la base de datos: $e');
    }
  }

  /// Inserta un nuevo evento en la base de datos.
  /// 
  /// [evento] es una instancia de `EventModel` que se convierte a un mapa.
  /// 
  /// Retorna el ID del evento insertado.
  Future<int> insertEvento(EventModel evento) async {
  final db = await database;

    return await db.insert(
      tableEventos,
      {
        'nombre': evento.nombre,
        'fecha': evento.fecha.toIso8601String(), // Guardar en formato ISO
        'ubicacion': evento.ubicacion,
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
    DateTime? fecha;
    try {
      // Intentar parsear la fecha en formato ISO 8601
      fecha = DateTime.parse(maps[i]['fecha']);
    } catch (e) {
      try {
        // Si falla el parseo ISO 8601, intenta con un formato diferente
        final DateFormat format = DateFormat('dd-MM-yyyy');
        fecha = format.parse(maps[i]['fecha']);
      } catch (e) {
        // Si ambos intentos fallan, asigna una fecha por defecto o maneja el error de alguna manera
        fecha = DateTime.now();  // O puedes lanzar una excepción si lo prefieres
      }
    }

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

  Future<void> eliminarTodosEventos() async {
  final db = await database;
  await db.delete(tableEventos); // nombre de la tabla
  }

  //Metodos para usuario

  /// Inserta un nuevo usuario en la base de datos.
  /// 
  /// [usuario] es una instancia de `UserModel` que se convierte a un mapa.
  /// 
  /// Retorna el ID del usuario insertado.
  Future<int> insertUsuario(UserModel usuario) async {
    final db = await database;
    return await db.insert(
      tableUsuarios,
      {
        'nombre': usuario.nombre,
        'email': usuario.email,
        'rol': usuario.rol,
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

  /// Asigna un monitor a un evento, actualizando el campo `id_usuario` del evento.
  /// 
  /// [eventoId] es el ID del evento al que se le asignará el monitor.
  /// [monitorId] es el ID del monitor (usuario) que se asignará al evento.
  /// 
  /// Retorna el número de filas afectadas (1 si la asignación fue exitosa).
  Future<int> asignarMonitorAEvento(int eventoId, int monitorId) async {
    final db = await database;

    // Actualizamos el campo `id_usuario` del evento con el ID del monitor.
    return await db.update(
      tableEventos,
      {'id_usuario': monitorId}, // Asignamos el ID del monitor al campo id_usuario
      where: 'id_evento = ?',
      whereArgs: [eventoId],
    );
  }

}
