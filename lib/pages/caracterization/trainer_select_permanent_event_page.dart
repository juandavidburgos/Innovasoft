import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:flutter/material.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';

class TrainerSelectPermanentEventPage extends StatefulWidget {
  const TrainerSelectPermanentEventPage({super.key});

  @override
  State<TrainerSelectPermanentEventPage> createState() => TrainerSelectPermanentEventPageState();
}

class TrainerSelectPermanentEventPageState extends State<TrainerSelectPermanentEventPage> {
  final EventRepository _eventRepo = EventRepository();

  String nombreUsuario = 'Adrian Delgado';
  int usuarioId = 5; // Simulado
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
      //'/register_asistence',
      '/check_assistant',
      arguments: eventoSeleccionado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo y frase centrados
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    Image.asset(
                      'assets/images/logo_indeportes.png',
                      width: 250,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '“Indeportes somos todos”',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              
              const Divider(
                thickness: 1.5,
                color: Color(0xFFCCCCCC),
                height: 30,
              ),
              const SizedBox(height: 20),
              // Texto centrado para selección de evento
              const Center(
                child: Text(
                  'Seleccione el evento asignado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              _buildDropdownEventos(),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton('Comenzar registro', const Color(0xFF00944C), _iniciarRegistro),
                  Align(
                  alignment: Alignment.bottomCenter,
                  child: ActionButton(
                    text: 'Regresar',
                    color: Color.fromARGB(255, 134, 134, 134),
                    icono: Icons.arrow_back,
                    ancho: 145,
                    alto: 48,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/trainer_home');
                      },
                  ),
                ),
                ],
              ),
            ],
          ),
        ),
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
  return MainButton(
    onPressed: onPressed,
    color: color,
    texto:text,
  );
}

}