import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';

/// Servicio local que gestiona operaciones CRUD con una base de datos SQLite.
/// Utiliza el paquete `sqflite` para almacenar eventos en el dispositivo.
class LocalService {


  /// * Métodos asociados a los eventos
  
  // Eliminar tabla eventos
  Future <void> eliminarTablaEventos() async{
    await DatabaseService.db.deleteDB();
  }

  //Insertar Evento
  Future <int> guardarEvento(EventModel evento) async{
    return await DatabaseService.db.insertEvento(evento);
  }

  //Obtener eventos activos
  Future<List<EventModel>> obtenerEventosActivos({bool soloActivos = false}) async{
    return await DatabaseService.db.getEventos(soloActivos: soloActivos);
  }
  //Actualizar evento
  Future<int> editarEvento(EventModel evento) {
    return DatabaseService.db.updateEvento(evento);
  }

  //Deshabilitar eevento
  Future<int> inactivarEvento(int eventoId) {
    return  DatabaseService.db.deshabilitarEvento(eventoId);
  }

  //Eliminar evento
  Future<int> eliminarEvento(int eventoId) async {
    return await DatabaseService.db.deleteEvento(eventoId);
  }

  //Eliminar todos los eventos
  Future <void> eliminarTodosLosEventos () async{
    await DatabaseService.db.deleteAllEvents();
  }

  // Asignar un monitor a un evento
  Future <int> asignarMonitor (int eventId, int monitorId) async{
    return await DatabaseService.db.assingTrainer(eventId, monitorId);
  }

  //Obtener eventos con sus respectivos monitores asignados
  Future<List<EventModel>> obtenerEventosConMonitoresAsignados() async{
    return await DatabaseService.db.getAssingsEvents();
  }

  ///Métodos asociados a los usuarios
  
  //Guardar usuario
  Future<int> guardarUsuario(UserModel usuario) async{

    return await DatabaseService.db.insertUser(usuario);
  } 

  //Obtener usuarios
  Future<List<UserModel>> obtenerUsuarios() async{

    return await DatabaseService.db.getUsuarios();
  }

  //Actualizar usuario
  Future<int> editarUusario(UserModel usuario) async{

    return await DatabaseService.db.updateUsuario(usuario);
  }

  //Eliminar usuairo
  Future<int> eliminarUsuario(int id) async{
    return await DatabaseService.db.deleteUsuario(id);
  }

  // Verificar correo
  Future<bool> verificarCorreo(String email) async{
    return await DatabaseService.db.existeCorreo(email);
  }

  //Verifiar usuario por correo
  Future<bool> verificarUsuarioPorCorreo(String email) async{
    return await DatabaseService.db.existeUsuarioPorCorreo(email);
  }

}