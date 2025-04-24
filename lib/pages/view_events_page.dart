/*import 'package:flutter/material.dart';
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
}*/

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

/// Vista que muestra la lista de eventos almacenados localmente.
class ViewEventsPage extends StatefulWidget {
  const ViewEventsPage({super.key});

  @override
  State<ViewEventsPage> createState() => _ViewEventsPageState();
}

class _ViewEventsPageState extends State<ViewEventsPage> {
  final EventRepository _repo = EventRepository();
  List<EventModel> _eventos = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  /// Carga todos los eventos.
  Future<void> _cargarEventos() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _eventos = eventos;
    });
  }

  /// Elimina todos los eventos con confirmación.
  Future<void> _eliminarTodosEventos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar todos los eventos?'),
        content: const Text('Esta acción no se puede deshacer. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.eliminarTodosEventos();
      _cargarEventos(); // Recargar lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los eventos fueron eliminados')),
      );
    }
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _eliminarTodosEventos,
        child: const Icon(Icons.delete),
        tooltip: 'Eliminar todos los eventos',
      ),
    );
  }
}

