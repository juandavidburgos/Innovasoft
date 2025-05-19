import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../repositories/register_repository.dart';

class CheckAssistantPage extends StatefulWidget {
  final EventModel evento;

  const CheckAssistantPage({super.key, required this.evento});

  @override
  State<CheckAssistantPage> createState() => _CheckAssistantPageState();
}

class _CheckAssistantPageState extends State<CheckAssistantPage> {
  final RegisterRepository _registerRepository = RegisterRepository();
  List<Map<String, dynamic>> asistentes = [];
  Map<int, bool> checks = {};
  bool isLoading = true;

  late int idUsuario;

  EventModel get evento => widget.evento;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    idUsuario = 5; // Simulado
    _loadAsistentes();
  }

  Future<void> _loadAsistentes() async {
    final int? idEvento = evento.idEvento;

    if (idEvento != null) {
      final result = await _registerRepository.obtenerAsistentesFormulario(idUsuario, idEvento);
      setState(() {
        asistentes = result;
        checks = {for (var a in asistentes) a['formulario_id'] as int: false};
        isLoading = false;
      });
    } else {
      setState(() {
        asistentes = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: El evento no está disponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Asistentes'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : asistentes.isEmpty
              ? const Center(child: Text('No hay asistentes registrados para este evento.'))
              : ListView.builder(
                  itemCount: asistentes.length,
                  itemBuilder: (context, index) {
                    final asistente = asistentes[index];
                    final id = asistente['formulario_id'] as int;
                    return CheckboxListTile(
                      title: Text(asistente['nombre'] ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Correo: ${asistente['correo'] ?? 'N/A'}'),
                          Text('ID: ${asistente['identificacion'] ?? 'N/A'}'),
                        ],
                      ),
                      value: checks[id],
                      onChanged: (bool? value) {
                        setState(() {
                          checks[id] = value ?? false;
                        });
                      },
                    );
                  },
                ),
    );
  }
}

