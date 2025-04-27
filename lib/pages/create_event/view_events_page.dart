import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';

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
      appBar: AppBar(title: const Text('Eventos Creados'),backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: _eventos.isEmpty
        ? const Center(child: Text('No hay eventos registrados.'))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _eventos.length,
            itemBuilder: (context, index) {
              final evento = _eventos[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6), // separación mínima entre eventos
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // marco alrededor del evento
                  borderRadius: BorderRadius.circular(10), // bordes redondeados
                  color: Colors.white, // opcional: fondo blanco
                ),
                child: ListTile(
                  title: Text(
                    evento.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Fecha: ${evento.fecha} - Estado: ${evento.estado}'),
                  trailing: Text('ID: ${evento.idEvento}'),
                ),
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

