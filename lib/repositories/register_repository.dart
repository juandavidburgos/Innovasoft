import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:flutter/material.dart';
import '../services/local_service.dart';

class RegisterRepository {
  final LocalService _localService = LocalService();

  Future<void> guardarFormulario(FormModel formulario) async {
    await _localService.guardarFormularioLocal(formulario);
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

  Future<List<AnswerModel>> obtenerRespuestasGuardadas(int formularioId) {
    return _localService.obtenerRespuestas(formularioId);
  }

  Future<void> eliminarFormularioGuardado(int formularioId) {
    return _localService.eliminarFormularioYRespuestas(formularioId);
  }
}
