import 'package:flutter/material.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';

class TrainerSelectEventPage extends StatefulWidget {
  const TrainerSelectEventPage({super.key});

  @override
  State<TrainerSelectEventPage> createState() => TrainerSelectEventPageState();
}

class TrainerSelectEventPageState extends State<TrainerSelectEventPage> {

  List<EventModel> eventosAsignados = [];
  EventModel? eventoSeleccionado;


  final EventRepository _eventRepo = EventRepository();


  String nombreUsuario = '';
  int usuarioId = 0;
  EventModel? eventoAsignado;

  @override
  void initState() {
    super.initState();
    _cargarSesionYEvento();
  }

  Future<void> _cargarSesionYEvento() async {
    await _cargarSesion();

    final eventos = await _eventRepo.obtenerEventos();
    final asignados = eventos.where((e) => e.idUsuario == usuarioId).toList();

    setState(() {
      eventosAsignados = asignados;
      if (asignados.length == 1) {
        eventoSeleccionado = asignados.first;
      }
    });
  }


  Future<void> _cargarSesion() async {
    // Simulación: reemplaza con SharedPreferences o SessionService
    setState(() {
      nombreUsuario = 'Carlos Ramírez';
      usuarioId = 1; // Debe venir de sesión real
    });
  }

  Future<EventModel?> obtenerEventoAsignadoAlEntrenador(int idEntrenador) async {
    try {
      final eventos = await _eventRepo.obtenerEventos();

      final eventoAsignado = eventos.firstWhere(
        (evento) => evento.idUsuario == idEntrenador,
        orElse: () => throw Exception('No se encontró evento asignado al entrenador.'),
      );

      return eventoAsignado;
    } catch (e) {
      debugPrint('Error al obtener evento del entrenador: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el evento asignado al entrenador.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar evento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, $nombreUsuario', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildAsignacionDropdown(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: eventoSeleccionado != null
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/register_asistence',
                        arguments: eventoSeleccionado,
                      );
                    }
                  : null,
              child: const Text('Comenzar registro'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAsignacionDropdown() {
    if (eventosAsignados.isEmpty) {
      return const Text('No tienes eventos asignados.');
    }

    return DropdownButtonFormField<EventModel>(
      decoration: const InputDecoration(labelText: 'Seleccione un evento asignado'),
      value: eventoSeleccionado,
      items: eventosAsignados.map((evento) {
        return DropdownMenuItem<EventModel>(
          value: evento,
          child: Text('${evento.nombre} - ${evento.fechaHoraInicio.toLocal().toIso8601String().substring(0, 10)}'),
        );
      }).toList(),
      onChanged: (evento) {
        setState(() {
          eventoSeleccionado = evento;
        });
      },
    );
  }
}

