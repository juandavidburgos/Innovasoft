import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../models/event_assignment_model.dart';
import '../../repositories/assignment_repository.dart';

class ViewAssignmentPage extends StatefulWidget {
  const ViewAssignmentPage({super.key});

  @override
  State<ViewAssignmentPage> createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  final AssignmentRepository _assignmentRepo = AssignmentRepository();

  List<EventoAsignacionModel> _eventos = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarEventosAsignados();
  }

  Future<void> _cargarEventosAsignados() async {
    setState(() {
      _cargando = true;
    });

    try {
      final data = await _assignmentRepo.fetchAsignacionesPorEventoRemoto();

      // ✅ Aseguramos que cada elemento es un Map<String, dynamic>
      final eventos = (data as List<dynamic>)
          .map((e) => EventoAsignacionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // ✅ Conversión de string a DateTime para comparar fechas
      eventos.sort((a, b) {
        final estadoA = DateTime.parse(a.fecha_hora_fin).isAfter(DateTime.now()) ? 'activo' : 'finalizado';
        final estadoB = DateTime.parse(b.fecha_hora_fin).isAfter(DateTime.now()) ? 'activo' : 'finalizado';

        if (estadoA != estadoB) return estadoA == 'activo' ? -1 : 1;

        return DateTime.parse(a.fecha_hora_inicio).compareTo(DateTime.parse(b.fecha_hora_inicio));
      });

      setState(() {
        _eventos = eventos;
      });
    } catch (e) {
      print('Error al cargar asignaciones: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las asignaciones.')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // ✅ Acepta String y convierte a DateTime
  String formatearFecha(String fechaStr) {
    final fecha = DateTime.parse(fechaStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualización de Asignaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEventosAsignados,
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _eventos.isEmpty
              ? const Center(child: Text('No hay eventos asignados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _eventos.length,
                  itemBuilder: (context, index) {
                    final evento = _eventos[index];
                    final estado = DateTime.parse(evento.fecha_hora_fin).isAfter(DateTime.now()) ? 'activo' : 'finalizado';
                    final nombresMonitores = evento.monitoresAsignados.map((m) => m.nombre).join(', ');

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(evento.nombre),
                        subtitle: Text(
                          'Ubicación: ${evento.ubicacion}\n'
                          'Inicio: ${formatearFecha(evento.fecha_hora_inicio)}\n'
                          'Fin: ${formatearFecha(evento.fecha_hora_fin)}\n'
                          'Entrenadores: $nombresMonitores',
                        ),
                        trailing: Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            color: estado == 'activo' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

//Visualizar de manera local
/*class ViewAssignmentPage extends StatefulWidget {
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
}*/