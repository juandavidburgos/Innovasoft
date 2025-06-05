import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // ✅ YA VIENE COMO List<EventoAsignacionModel>
    final eventos = await _assignmentRepo.fetchAsignacionesPorEventoRemoto();

    setState(() {
      _eventos = eventos;
      print('Eventos cargados:');
      for (var evento in eventos) {
        print('Evento: ${evento.nombre}, Monitores: ${evento.monitoresAsignados.map((e) => e.nombre).toList()}');
      }

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