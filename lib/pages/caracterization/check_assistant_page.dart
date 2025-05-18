import 'package:flutter/material.dart';
import '../../models/answer_model.dart';
import '../../models/event_model.dart';
import '../../services/data_service.dart';

class CheckAssistantPage extends StatefulWidget {
  final EventModel evento;

  const CheckAssistantPage({Key? key, required this.evento}) : super(key: key);

  @override
  State<CheckAssistantPage> createState() => _CheckAssistantPageState();
}

class _CheckAssistantPageState extends State<CheckAssistantPage> {
  final DatabaseService _dataService = DatabaseService();

  List<Map<String, dynamic>> asistentes = []; // {'nombre': ..., 'identificacion': ..., 'marcado': ...}
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAsistentes();
  }

  Future<void> _cargarAsistentes() async {
    final formularios = await _dataService.getFormsByEvent(widget.evento.idEvento);
    
    List<Map<String, dynamic>> tempAsistentes = [];

    for (var form in formularios) {
      final respuestas = await _dataService.getAnswers(form.idFormulario);

      String? nombre;
      String? identificacion;

      for (var resp in respuestas) {
        if (resp.preguntaId == 1) {
          nombre = resp.contenido;
        } else if (resp.preguntaId == 2) {
          identificacion = resp.contenido;
        }
      }

      if (nombre != null && identificacion != null) {
        tempAsistentes.add({
          'nombre': nombre,
          'identificacion': identificacion,
          'marcado': false,
        });
      }
    }

    setState(() {
      asistentes = tempAsistentes;
      isLoading = false;
    });
  }

  void _toggleCheck(int index, bool? value) {
    setState(() {
      asistentes[index]['marcado'] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistentes - ${widget.evento.nombre}'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: asistentes.length,
              itemBuilder: (context, index) {
                final asistente = asistentes[index];
                return CheckboxListTile(
                  title: Text(asistente['nombre']),
                  subtitle: Text('ID: ${asistente['identificacion']}'),
                  value: asistente['marcado'],
                  onChanged: (value) => _toggleCheck(index, value),
                );
              },
            ),
    );
  }
}
