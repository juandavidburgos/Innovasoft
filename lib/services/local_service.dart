import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'dart:async';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'local_data_service.dart';

/// Servicio local que gestiona operaciones CRUD con una base de datos SQLite.
/// Utiliza el paquete `sqflite` para almacenar eventos en el dispositivo.
class LocalService {


  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A EVENTOS
  /// -------------------------------------------------
  
  // Eliminar tabla eventos
  Future <void> eliminarTablaEventos() async{
    await LocalDataService.db.deleteDB();
  }

  //Insertar Evento
  Future <int> guardarEvento(EventModel evento) async{
    return await LocalDataService.db.insertEvento(evento);
  }

  //Guardar lista de eventos
  Future<void> guardarEventosLocalmente(List<EventModel> eventos) async {
    return await LocalDataService.db.insertEventList(eventos);
  }

  //Obtener eventos activos
  Future<List<EventModel>> obtenerEventosActivos({bool soloActivos = false}) async{
    return await LocalDataService.db.getEventos(soloActivos: soloActivos);
  }
  //Actualizar evento
  Future<int> editarEvento(EventModel evento) {
    return LocalDataService.db.updateEvento(evento);
  }

  //Deshabilitar eevento
  Future<int> inactivarEvento(int eventoId) {
    return  LocalDataService.db.deshabilitarEvento(eventoId);
  }

  //Eliminar evento
  Future<int> eliminarEvento(int eventoId) async {
    return await LocalDataService.db.deleteEvento(eventoId);
  }

  //Eliminar todos los eventos
  Future <void> eliminarTodosLosEventos () async{
    await LocalDataService.db.deleteAllEvents();
  }

  
  Future<List<Map<String, dynamic>>> obtenerEventosConEntrenadoresAsignados() async {
  // Llamamos al método de la base de datos para traer los eventos y los entrenadores
    return await LocalDataService.db.getAssignedEvents();
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A ASIGNACIONES
  /// -------------------------------------------------

  // Asignar un solo entrenador a un evento
  Future<bool> asignarEntrenador(int eventId, int trainerId) async {
    return await LocalDataService.db.assignTrainer(eventId, trainerId);
  }

  // Asignar uno o más entrenadores a un evento
  Future<int> asignarEntrenadores(int eventId, List<int> trainerIds) async {
    return await LocalDataService.db.assignTrainers(eventId, trainerIds);
  }

  // Actualizar asignaciones de entrenadores para un evento
  Future<bool> actualizarAsignacionesDeEvento(int eventId, List<int> trainerIds) async {
    return await LocalDataService.db.updateEventAssignments(eventId, trainerIds);
  }

  // Actualizar asignaciones de eventos para un monitor
  Future<bool> actualizarAsignacionesDeMonitor(int monitorId, List<int> eventosIds) async {
    return await LocalDataService.db.updateEventosDeMonitor(monitorId, eventosIds);
  }

  // Obtener lista de eventos que tienen entrenadores asignados (para mostrar en un dropdown)
  Future<List<Map<String, dynamic>>> obtenerAsignacionesConNombreEvento() async {
    return await LocalDataService.db.getAsignacionesConNombreEvento();
  }

  //Obtener evento asignado
  Future<List<EventModel>> obtenerEventosAsignados(int idUsuario) async {
    final data = await LocalDataService.db.obtenerEventosAsignadosPorUsuario(idUsuario);
    return data.map((map) => EventModel.fromMap(map)).toList();
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A USUARIOS
  /// -------------------------------------------------

  
  //Guardar usuario
  Future<int> guardarUsuario(UserModel usuario) async{
    final existe = await LocalDataService.db.existeCorreo(usuario.email);
      if (!existe) {
        return await LocalDataService.db.insertUser(usuario);
      } else {
        return -1;
      }
    
  } 

  // Obtener entrenadores asignados a un evento específico
  Future<List<Map<String, dynamic>>> obtenerEntrenadoresPorEvento(int eventId) async {
    return await LocalDataService.db.getTrainersByEvento(eventId);
  }

  //Obtener usuarios
  Future<List<UserModel>> obtenerEntrenadoresActivos() async{

    return await LocalDataService.db.getEntrenadoresActivos();
  }

  //Obtener todos los entrenadores
  Future<List<UserModel>> obtenerEntrenadores() async{

    return await LocalDataService.db.getEntrenadores();
  }

 //Obtener usuarios
  Future<List<UserModel>> obtenerUsuarios() async{

    return await LocalDataService.db.getUsuarios();
  }

  //Actualizar usuario
  Future<int> editarUusario(UserModel usuario) async{

    return await LocalDataService.db.updateUsuario(usuario);
  }

  //Eliminar usuairo
  Future<int> eliminarUsuario(int id) async{
    return await LocalDataService.db.deleteUsuario(id);
  }

  Future<int> deshabilitarEntrenador(int id) async{
    return await LocalDataService.db.disableUser(id);
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A FORMULARIOS Y RESPUESTAS
  /// -------------------------------------------------
  
  //Guardar formulario
  Future<void> guardarFormularioLocal(FormModel formulario) async{
    await LocalDataService.db.insertForm(formulario);
  }

  //Guardar formulario
  Future<List<FormModel>> obtenerFormularios()  async{
    return await LocalDataService.db.getForms();
  }

  //Guardar respuestas
  Future<void> guardarRespuestasLocales(List<AnswerModel> respuestas) async{
    await LocalDataService.db.insertAnswer(respuestas);
  }
  //Guardar respuestas
  Future<List<AnswerModel>> obtenerRespuestas(int formularioId) async{
    return await LocalDataService.db.getAnswers(formularioId);
  }

  //Eliminar formulario
  
  Future<void> eliminarFormularioYRespuestas(int formularioId) async{
    return await LocalDataService.db.deleteFormAnswers(formularioId);
  }

  /// Obtener asistentes del formulario para un entrenador y evento específico
  Future<List<Map<String, dynamic>>> obtenerAsistentesFormulario(int userId, int eventId) async {
    return await LocalDataService.db.getAsistentesFormulario(userId, eventId);
  }

  //Verificar los formularios registrados en la cola de peticiones
  Future<bool> hayFormulariosRegistrados() async {
    return await LocalDataService.db.hayFormulariosRegistrados();
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A AUTENTICACIÓN DE USUARIOS
  /// -------------------------------------------------

  // Verificar correo
  Future<bool> verificarCorreo(String email) async{
    return await LocalDataService.db.existeCorreo(email);
  }

  //Verifiar usuario por correo
  Future<bool> verificarUsuarioPorCorreo(String email) async{
    return await LocalDataService.db.existeUsuarioPorCorreo(email);
  }

  Future<void> crearAdminTemporal() async{
    return await LocalDataService.db.crearAdminTemporal();
  }

  Future<List<UserModel>> obtenerUsuariosNoSincronizados() async {
    return await LocalDataService.db.getNoSyncUsers();
  }

  Future<void> marcarUsuarioComoSincronizado(int idUsuario) async {
    return await LocalDataService.db.markUserSync(idUsuario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LA COLA DE PETICIONES
  /// -------------------------------------------------
  
  Future<void> guardarEnColaPeticiones(FormModel formulario, List<AnswerModel> respuestas) async {
    return await LocalDataService.db.guardarEnCola(formulario, respuestas);

  }

  Future<void> guardarEvidenciaEnColaPeticiones(FormModel formulario) async {
    return await LocalDataService.db.guardarEvidenciaEnCola(formulario);
  }

  /// -------------------------------------------------
  /// *MÉTODOS ASOCIADOS A LA CONEXIÓN A INTERNET
  /// -------------------------------------------------
  
  Future<bool> detectarConexion() async {
    return await LocalDataService.db.hayInternet();
  }
}