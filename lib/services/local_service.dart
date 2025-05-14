import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/event_model.dart';
import '../models/user_model.dart';
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

  // Asignar uno o más entrenadores a un evento
  Future<int> asignarEntrenadores(int eventId, List<int> trainerIds) async {
    return await DatabaseService.db.assignTrainers(eventId, trainerIds);
  }

  // Obtener eventos que tienen al menos un entrenador asignado
  /*Future<List<EventModel>> obtenerEventosConEntrenadoresAsignados() async {
    return await DatabaseService.db.getAssignedEvents();
  }*/
  Future<List<Map<String, dynamic>>> obtenerEventosConEntrenadoresAsignados() async {
  // Llamamos al método de la base de datos para traer los eventos y los entrenadores
  return await DatabaseService.db.getAssignedEvents();

  }

  // Obtener los entrenadores asignados a un evento específico
  Future<List<Map<String, dynamic>>> obtenerEntrenadoresPorEvento(int eventId) async {
    return await DatabaseService.db.getTrainersByEventId(eventId);
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

  ///Métodos asociados al formulario
  
  //Guardar formulario
  Future<void> guardarFormularioLocal(FormModel formulario) async{
    await DatabaseService.db.insertForm(formulario);
  }

  //Guardar respuestas
  Future<void> guardarRespuestasLocales(List<AnswerModel> respuestas) async{
    await DatabaseService.db.insertAnswer(respuestas);
  }

  //Guardar formulario
  Future<List<FormModel>> obtenerFormularios()  async{
    return await DatabaseService.db.getForms();
  }

  //Guardar respuestas
  Future<List<AnswerModel>> obtenerRespuestas(int formularioId) async{
    return await DatabaseService.db.getAnswers(formularioId);
  }

  //Eliminar formulario
  
  Future<void> eliminarFormularioYRespuestas(int formularioId) async{
    return await DatabaseService.db.deleteFormAnswers(formularioId);
  }

  //Obtener evento asignado
  Future<List<EventModel>> obtenerEventosAsignados(int idUsuario) async {
    final data = await DatabaseService.db.obtenerEventosAsignadosPorUsuario(idUsuario);
    return data.map((map) => EventModel.fromMap(map)).toList();
  }
}