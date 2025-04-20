import 'package:flutter/material.dart';
import '../models/event_model.dart';
//import '../services/local_service.dart';
import '../repositories/event_repository.dart';

/// Vista que muestra la lista de eventos almacenados localmente.
class ViewEventsPage extends StatefulWidget {
  const ViewEventsPage({super.key});

  @override
  State<ViewEventsPage> createState() => _ViewEventsPageState();
}

class _ViewEventsPageState extends State<ViewEventsPage> {
  //final LocalService _service = LocalService();
  final EventRepository _repo = EventRepository();
  List<EventModel> _eventos = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  /// Carga todos los eventos, incluyendo los activos e inactivos.
  Future<void> _cargarEventos() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _eventos = eventos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos Creados')),

      body: _eventos.isEmpty
          ? const Center(child: Text('No hay eventos registrados.'))
          : ListView.builder(
              itemCount: _eventos.length,
              itemBuilder: (context, index) {
                final evento = _eventos[index];
                return ListTile(
                  title: Text(evento.nombre),
                  subtitle: Text('Fecha: ${evento.fecha} - Estado: ${evento.estado}'),
                  trailing: Text('ID: ${evento.idEvento}'),
                );
              },
            ),
    );
  }
}
