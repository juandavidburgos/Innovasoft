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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visualización de eventos',
          style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      backgroundColor: Colors.white,
      body: _eventos.isEmpty
          ? const Center(child: Text('No hay eventos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _eventos.length,
              itemBuilder: (context, index) {
                final evento = _eventos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evento.descripcion,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ubicación: ${evento.ubicacion}',
                      ),
                      Text(
                        'Fecha inicio: ${evento.fecha_hora_inicio.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'Fecha fin: ${evento.fecha_hora_fin.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'Estado: ${evento.estado}',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
