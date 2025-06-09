import 'package:basic_flutter/models/event_model.dart';

import '../models/form_model.dart';
import '../models/DTO/FormularioDTOPeticion.dart';
import '../models/answer_model.dart';
import '../services/local_service.dart';
import '../services/remote_service.dart';
import 'dart:io';

class FormsRepository {
  
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();
  
  Future<bool> enviarFormularioConRespuestas(FormModel formulario, List<AnswerModel> respuestas) async {
    return await _remoteService.enviarFormularioRespondido(formulario, respuestas);
  }

  Future<bool> enviarRespuestasFormulario(int idFormulario, int idEvento, List<AnswerModel> respuestas) async {
    return await _remoteService.enviarRespuestasFormulario( idFormulario, idEvento, respuestas);
  }

Future<List<EventModel>> obtenerEventos() {
    return _remoteService.obtenerEventosRemotos().then((eventos) {
      return eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  Future<FormularioDTOPeticion?> crearFormularioEnBackend(FormularioDTOPeticion form) async {
    return await _remoteService.crearFormularioRemoto(form);
  }

  Future<void> guardarEnColaPeticiones(FormModel formulario, List<AnswerModel> respuestas) async {
    return await _localService.guardarEnColaPeticiones(formulario, respuestas);
  }

  Future<bool> enviarEvidenciaEntrenador(FormModel formulario) async {
    return await _remoteService.enviarEvidencia(formulario);
  }

  Future<void> guardarEvidenciaEnColaPeticiones(FormModel formulario) async {
    return await _localService.guardarEvidenciaEnColaPeticiones(formulario);
  }

  Future<bool> hayConexion() async {
    return await _localService.detectarConexion();
  }

  Future<bool> hayFormulariosRegistrados() async {
    return await _localService.hayFormulariosRegistrados();
  }

  

  /// -------------------------------------------------
  /// *MÉTODO PARA EL REPORTE
  /// -------------------------------------------------
  
  Future<File?> descargarReporteExcel(int idEvento) async {
    return await _remoteService.obtenerReporteExcel(idEvento);
  }

}