import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';
import '../widgets/action_button.dart';

class TrainerAssignmentPage extends StatefulWidget {
  const TrainerAssignmentPage({super.key});

  @override
  State<TrainerAssignmentPage> createState() => _TrainerAssignmentPageState();
}

class _TrainerAssignmentPageState extends State<TrainerAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  final UserRepository _userRepo = UserRepository();
  final EventRepository _eventRepo = EventRepository();

  List<UserModel> _monitores = [];
  List<EventModel> _eventos = [];

  String? selectedMonitorId;
  String? selectedEventId;

  @override
  void initState() {
    super.initState();
    _cargarMonitores();
    _cargarEventos();
  }

  Future<void> _cargarMonitores() async {
    final usuarios = await _userRepo.obtenerUsuarios();
    setState(() {
      _monitores = usuarios.where((u) => u.rol == 'Monitor').toList();
    });
  }

  Future<void> _cargarEventos() async {
    final eventos = await _eventRepo.obtenerEventos();
    setState(() {
      _eventos = eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  Future<void> _asignarMonitor() async {
    if (selectedMonitorId != null && selectedEventId != null) {
      final result = await _eventRepo.asignarMonitorAEvento(
        int.parse(selectedEventId!),
        int.parse(selectedMonitorId!),
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrenador asignado con éxito')),
        );
        setState(() {
          selectedMonitorId = null;
          selectedEventId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al asignar entrenador')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un evento y un entrenador')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/indeportes_logo.png', width: 200),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('Asignar Entrenador a Evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildEventoDropdown(),
                const SizedBox(height: 20),
                _buildMonitorDropdown(),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'ASIGNAR',
                      color: Colors.green,
                      onPressed: _asignarMonitor,
                    ),
                    ActionButton(
                      text: 'VOLVER',
                      color: Colors.blue,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar evento',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _eventos.map((evento) {
        return DropdownMenuItem<String>(
          value: evento.idEvento.toString(),
          child: Text(evento.nombre),
        );
      }).toList(),
      value: selectedEventId,
      onChanged: (value) {
        setState(() {
          selectedEventId = value;
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildMonitorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar entrenador',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _monitores.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.idUsuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      value: selectedMonitorId,
      onChanged: (value) {
        setState(() {
          selectedMonitorId = value;
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}

/*import 'package:flutter/material.dart';
import 'widgets/action_button.dart';

class TrainerAssignmentPage extends StatefulWidget {
  const TrainerAssignmentPage({super.key});

  @override
  State<TrainerAssignmentPage> createState() => _TrainerAssignmentPageState();
}

class _TrainerAssignmentPageState extends State<TrainerAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedTrainer;
  String? selectedEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/indeportes_logo.png', width: 200),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('Asignar Entrenador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Dropdown para seleccionar entrenador (vacío por ahora)
                DropdownButtonFormField<String>(
                  value: selectedTrainer,
                  items: const [], // Se llenará más adelante
                  onChanged: (String? value) {
                    setState(() {
                      selectedTrainer = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Entrenador',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown para seleccionar evento (vacío por ahora)
                DropdownButtonFormField<String>(
                  value: selectedEvent,
                  items: const [], // Se llenará más adelante
                  onChanged: (String? value) {
                    setState(() {
                      selectedEvent = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Evento',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'ASIGNAR',
                      color: Colors.green,
                      onPressed: _assignTrainer,
                    ),
                    ActionButton(
                      text: 'VOLVER',
                      color: Colors.blue,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _assignTrainer() {
    if (selectedTrainer != null && selectedEvent != null) {
      Navigator.pushNamed(context, '/trainer_assigned');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un entrenador y un evento')),
      );
    }
  }
}*/
