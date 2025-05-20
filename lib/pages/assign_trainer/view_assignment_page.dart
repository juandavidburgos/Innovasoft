import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../repositories/assignment_repository.dart';

class ViewAssignmentPage extends StatefulWidget {
  const ViewAssignmentPage({super.key});

  @override
  State<ViewAssignmentPage> createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  final AssignmentRepository _assignmentRepo = AssignmentRepository();

  List<Map<String, dynamic>> _eventosAsignados = [];

  @override
  void initState() {
    super.initState();
    _cargarEventosAsignados();
  }

  Future<void> _cargarEventosAsignados() async {
    try {
      final eventos = await _assignmentRepo.obtenerEventosConEntrenadoresAsignados();

      eventos.sort((a, b) {
        final eventoA = a['evento'] as EventModel;
        final eventoB = b['evento'] as EventModel;

        // Ordenar por estado: activos primero
        if (eventoA.estado != eventoB.estado) {
          if (eventoA.estado == 'activo') return -1;
          if (eventoB.estado == 'activo') return 1;
        }

        // Si el estado es igual, ordenar por fecha de inicio
        return eventoA.fecha_hora_inicio.compareTo(eventoB.fecha_hora_inicio);
      });

      setState(() {
        _eventosAsignados = eventos;
      });
    } catch (e) {
      print('Error al cargar eventos asignados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los eventos asignados.')),
      );
    }
  }

  String formatearFecha(DateTime fecha) {
    final formato = DateFormat('dd/MM/yyyy HH:mm');
    return formato.format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visualización de asignaciones',
          style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _eventosAsignados.isEmpty
              ? const Center(child: Text('No hay asignaciones disponibles.'))
              : ListView.builder(
                  itemCount: _eventosAsignados.length,
                  itemBuilder: (context, index) {
                    final item = _eventosAsignados[index];
                    final EventModel evento = item['evento'];
                    final String entrenadores = item['entrenadores'] ?? 'No asignados';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(evento.nombre),
                        subtitle: Text(
                          'Ubicación: ${evento.ubicacion}\n'
                          'Descripción: ${evento.descripcion}\n'
                          'Inicio: ${formatearFecha(evento.fecha_hora_inicio)}\n'
                          'Fin: ${formatearFecha(evento.fecha_hora_fin)}\n'
                          'Entrenadores: $entrenadores',
                        ),
                        trailing: Text(
                          evento.estado.toUpperCase(),
                          style: TextStyle(
                            color: evento.estado == 'activo' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

