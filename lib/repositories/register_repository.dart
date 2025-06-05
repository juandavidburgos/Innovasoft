import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/models/question_model.dart';
import '../services/local_service.dart';

class RegisterRepository {
  final LocalService _localService = LocalService();

  ///
  /// MÉTODOS DE GESTIÓN LOCAL
  /// 

  /// --------------------------------------------------------
  /// Formularios:
  /// 

  Future<int> guardarFormulario(FormModel formulario) async {
    return await _localService.guardarFormularioLocal(formulario);
  }

  Future<void> guardarRespuestas(List<AnswerModel> respuestas) async {
    await _localService.guardarRespuestasLocales(respuestas);
  }

  Future<void> guardarFormularioCompleto({
    required FormModel formulario,
    required List<AnswerModel> respuestas,
  }) async {
    await guardarFormulario(formulario);
    await guardarRespuestas(respuestas);
  }

  Future<List<FormModel>> obtenerFormulariosGuardados() {
    return _localService.obtenerFormularios();
  }

  Future<int?> obtenerFormularioId(int idUsuario, int idEvento) async {
    return await _localService.obtenerFormularioId(idUsuario, idEvento);
  }

  Future<List<QuestionModel>> obtenerPreguntasPorFormulario(int formularioId) async {
    return await _localService.obtenerPreguntasPorFormulario(formularioId);
  }

  Future<List<AnswerModel>> obtenerRespuestasGuardadas(int formularioId) {
    return _localService.obtenerRespuestas(formularioId);
  }

  Future<void> eliminarFormularioGuardado(int formularioId) {
    return _localService.eliminarFormularioYRespuestas(formularioId);
  }

  Future<List<Map<String, dynamic>>> obtenerAsistentesFormulario(int userId, int eventId) {
    return _localService.obtenerAsistentesFormulario(userId, eventId);
  }

}
