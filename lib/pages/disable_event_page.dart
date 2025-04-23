import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import 'confirm_disable_page.dart';

/// Página para seleccionar uno o varios eventos que se desean deshabilitar.
/// Solo se muestran los eventos con estado "activo".
class DisableEventPage extends StatefulWidget {
  const DisableEventPage({super.key});

  @override
  State<DisableEventPage> createState() => _DisableEventPageState();
}

class _DisableEventPageState extends State<DisableEventPage> {
  final EventRepository _repo = EventRepository();
  final List<int> _selectedEventIds = [];
  List<EventModel> _activeEvents = [];

  @override
  void initState() {
    super.initState();
    _loadActiveEvents();
  }

  /// Carga los eventos con estado "activo" desde el repositorio.
  void _loadActiveEvents() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _activeEvents = eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  /// Redirige a la página de confirmación con los IDs seleccionados.
  void _goToConfirmPage() {
    if (_selectedEventIds.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmDisablePage(idsEventos: _selectedEventIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deshabilitar Evento")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Selecciona los eventos a deshabilitar:"),
          Expanded(
            child: ListView.builder(
              itemCount: _activeEvents.length,
              itemBuilder: (context, index) {
                final evento = _activeEvents[index];
                return CheckboxListTile(
                  title: Text(evento.nombre),
                  subtitle: Text('${evento.ubicacion} - ${evento.fecha.toLocal().toString().split(' ')[0]}'),
                  value: _selectedEventIds.contains(evento.idEvento),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedEventIds.add(evento.idEvento!);
                      } else {
                        _selectedEventIds.remove(evento.idEvento);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _goToConfirmPage,
            child: const Text("Continuar"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
