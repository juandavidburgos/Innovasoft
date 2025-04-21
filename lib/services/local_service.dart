import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

/// Servicio local que gestiona operaciones CRUD con una base de datos SQLite.
/// Utiliza el paquete `sqflite` para almacenar eventos en el dispositivo.
class LocalService {
  /// Instancia privada de la base de datos.
  static Database? _db;

  /// Nombre de la tabla donde se almacenan los eventos.
  static const String tableEventos = 'eventos';

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
      return await openDatabase(path, version: 1, onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableEventos (
            id_evento INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            fecha TEXT NOT NULL,
            ubicacion TEXT NOT NULL,
            id_usuario INTEGER,
            estado TEXT CHECK(estado IN ('activo', 'inactivo')) DEFAULT 'activo'
          );
        ''');
      });
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
}
