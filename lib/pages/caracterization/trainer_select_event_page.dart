import 'package:flutter/material.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';

class TrainerSelectEventPage extends StatefulWidget {
  const TrainerSelectEventPage({super.key});

  @override
  State<TrainerSelectEventPage> createState() => _TrainerSelectEventPageState();
}

class _TrainerSelectEventPageState extends State<TrainerSelectEventPage> {
  final EventRepository _eventRepo = EventRepository();

  String nombreUsuario = 'Carlos Ramírez';
  int usuarioId = 1; // Simulado
  List<EventModel> eventosAsignados = [];
  EventModel? eventoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarEventosAsignados();
  }

  Future<void> _cargarEventosAsignados() async {
    final eventos = await _eventRepo.obtenerEventosDelEntrenador(usuarioId);
    setState(() {
      eventosAsignados = eventos;
    });
  }

  void _iniciarRegistro() {
    if (eventoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione un evento antes de continuar.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/register_asistence',
      arguments: eventoSeleccionado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Indeportes Cauca'),
        backgroundColor: const Color(0xFF004A7F),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bienvenido, $nombreUsuario',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          const Text(
            'Seleccionar evento asignado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildDropdownEventos(),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('COMENZAR REGISTRO', const Color(0xFF00944C), _iniciarRegistro),
              _buildButton('VOLVER', const Color(0xFF004A7F), () => Navigator.pushReplacementNamed(context,'/admin_home')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownEventos() {
    if (eventosAsignados.isEmpty) {
      return const Text(
        'No tienes eventos asignados.',
        style: TextStyle(fontSize: 16),
      );
    }

    return DropdownButtonFormField<EventModel>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: eventoSeleccionado,
      hint: const Text('Seleccionar evento'),
      items: eventosAsignados.map((evento) {
        final fecha = evento.fechaHoraInicio.toLocal().toIso8601String().substring(0, 10);
        return DropdownMenuItem<EventModel>(
          value: evento,
          child: Text('${evento.nombre} - $fecha'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          eventoSeleccionado = value;
        });
      },
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white, // ✅ Texto blanco sin "morado"
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      elevation: 2,
    ),
    child: Text(text),
  );
}

}
