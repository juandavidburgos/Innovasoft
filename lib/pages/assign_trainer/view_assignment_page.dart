import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/user_repository.dart';

class ViewAssignmentPage extends StatefulWidget {
  const ViewAssignmentPage({super.key});

  @override
  State<ViewAssignmentPage> createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  final EventRepository _eventRepo = EventRepository();
  final UserRepository _userRepo = UserRepository();

  List<EventModel> _eventosConMonitores = [];
  List<UserModel> _monitores = [];

  @override
  void initState() {
    super.initState();
    _cargarMonitoresYEventos();
  }

  Future<void> _cargarMonitoresYEventos() async {
    try {
      final eventos = await _eventRepo.obtenerEventos();
      final usuarios = await _userRepo.obtenerUsuarios();

      setState(() {
        // Obtener los usuarios con rol 'Monitor'
        _monitores = usuarios.where((usuario) => usuario.rol == 'Monitor').toList();

        // Filtrar eventos con idUsuario no nulo y que correspondan a un monitor válido
        _eventosConMonitores = eventos.where((evento) {
          return evento.idUsuario != null &&
              _monitores.any((monitor) => monitor.idUsuario == evento.idUsuario);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los eventos o monitores.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Asignaciones'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _eventosConMonitores.isEmpty
              ? const Center(child: Text('No hay asignaciones disponibles.'))
              : ListView.builder(
                  itemCount: _eventosConMonitores.length,
                  itemBuilder: (context, index) {
                    final evento = _eventosConMonitores[index];

                    // Ya se validó que el evento tiene un monitor
                    final monitor = _monitores.firstWhere(
                      (usuario) => usuario.idUsuario == evento.idUsuario,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(evento.nombre),
                        subtitle: Text(
                          'Monitor: ${monitor.nombre}\n'
                          'Ubicación: ${evento.ubicacion}\n'
                          'Descripción: ${evento.descripcion}\n'
                          'Inicio: ${evento.fechaHoraInicio.toLocal().toString()}\n'
                          'Fin: ${evento.fechaHoraFin.toLocal().toString()}',
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

