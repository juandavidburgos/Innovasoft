import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/assignment_repository.dart';
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
  final AssignmentRepository _assignmentRepo = AssignmentRepository();

  List<UserModel> _monitores = [];
  List<EventModel> _eventos = [];

  String? selectedEventId;
  int trainerCount = 0;
  List<String?> selectedTrainerIds = [];

  @override
  void initState() {
    super.initState();
    _cargarMonitores();
    _cargarEventos();
  }

  Future<void> _cargarMonitores() async {
    final usuarios = await _userRepo.obtenerUsuarios();
    setState(() {
      _monitores = usuarios.where((u) => u.rol == 'ENTRENADOR').toList();
    });
  }

  Future<void> _cargarEventos() async {
    final eventos = await _eventRepo.obtenerEventos();
    setState(() {
      _eventos = eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  Future<void> _asignarEntrenadores() async {
    if (selectedEventId == null || selectedTrainerIds.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona evento y todos los entrenadores')),
      );
      return;
    }

    final ids = selectedTrainerIds.map((id) => int.parse(id!)).toList();

    final result = await _assignmentRepo.asignarEntrenadoresAEvento(
      int.parse(selectedEventId!),
      ids,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result == ids.length
            ? 'Entrenadores asignados con éxito'
            : 'Algunos entrenadores no se asignaron (ya podrían estar asignados)'),
      ),
    );

    if (result == ids.length) {
      setState(() {
        selectedEventId = null;
        trainerCount = 0;
        selectedTrainerIds = [];
      });
    }
  }

  List<UserModel> _monitoresDisponiblesPara(int index) {
    final idsSeleccionados = selectedTrainerIds.where((id) => id != null && selectedTrainerIds.indexOf(id) != index).toSet();
    return _monitores.where((m) => !idsSeleccionados.contains(m.idUsuario.toString())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool sinEventos = _eventos.isEmpty;
    final bool sinMonitores = _monitores.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 140),
                Image.asset('assets/images/logo2_indeportes.png', width: 400),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 40),
                const Text('Asignar Entrenadores a Evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                if (sinEventos || sinMonitores)
                  Column(
                    children: [
                      if (sinEventos) const Text('No hay eventos activos disponibles', style: TextStyle(color: Colors.red)),
                      if (sinMonitores) const Text('No hay entrenadores disponibles', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 30),
                      ActionButton(
                        text: 'Regresar',
                        color: Color.fromARGB(255, 134, 134, 134),
                        icono: Icons.arrow_back,
                        ancho: 145,
                        alto: 48,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildEventoDropdown(),
                      const SizedBox(height: 20),
                      _buildCantidadEntrenadoresDropdown(),
                      const SizedBox(height: 20),
                      for (int i = 0; i < trainerCount; i++) ...[
                        _buildTrainerDropdown(i),
                        const SizedBox(height: 15),
                      ],
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            text: 'Asignar',
                            color: Color(0xFF038C65),
                            ancho: 140,
                            alto: 48,
                            onPressed: _asignarEntrenadores,
                          ),
                          ActionButton(
                            text: 'Regresar',
                            color: Color.fromARGB(255, 134, 134, 134),
                            icono: Icons.arrow_back,
                            ancho: 145,
                            alto: 48,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
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

  Widget _buildCantidadEntrenadoresDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Cantidad de entrenadores',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: List.generate(10, (index) => index + 1).map((number) {
        return DropdownMenuItem<int>(
          value: number,
          child: Text(number.toString()),
        );
      }).toList(),
      value: trainerCount > 0 ? trainerCount : null,
      onChanged: (value) {
        setState(() {
          trainerCount = value!;
          selectedTrainerIds = List<String?>.filled(trainerCount, null);
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildTrainerDropdown(int index) {
    final disponibles = _monitoresDisponiblesPara(index);

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar entrenador ${index + 1}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: selectedTrainerIds[index],
      items: disponibles.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.idUsuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTrainerIds[index] = value;
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}