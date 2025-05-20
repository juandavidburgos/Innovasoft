import '../models/form_model.dart';
import '../models/answer_model.dart';
import '../services/local_service.dart';
import '../services/remote_service.dart';

class FormsRepository {
  
  final LocalService _localService = LocalService();
  final RemoteService _remoteService = RemoteService();
  
  Future<bool> enviarFormularioConRespuestas(FormModel formulario, List<AnswerModel> respuestas) async {
    return await _remoteService.enviarFormularioRespondido(formulario,  respuestas);
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
}