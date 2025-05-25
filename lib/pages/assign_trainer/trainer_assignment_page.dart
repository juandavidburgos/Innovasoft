import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/assignment_repository.dart';
import '../../models/event_model.dart';
import '../widgets/action_button.dart';
import 'assignment_success_page.dart';
import '../home/admin_trainer_home_page.dart';

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

  final List<int> _entrenadoresAsignados = [];
  final List<String> _nombresEntrenadoresAsignados = [];

  String? selectedEventId;
  String? selectedTrainerId;

  @override
  void initState() {
    super.initState();
    _cargarMonitores();
    _cargarEventos();
  }

  /*Future<void> _cargarMonitores() async {
    final usuarios = await _userRepo.obtenerUsuariosRemotos();
    setState(() {
      _monitores = usuarios.where((u) => u.rol == 'Monitor').toList();
    });
  }*/
  Future<void> _cargarMonitores() async {
    try {
      final usuarios = await _userRepo.obtenerUsuariosRemotos();
      if (!mounted) return;

      setState(() {
        _monitores = usuarios.where((u) => u.estado_monitor == 'activo').toList();
      });
    } catch (e) {
      print('Error al cargar monitores: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los monitores !!!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /*Future<void> _cargarEventos() async {
    final eventos = await _eventRepo.obtenerEventosRemotos();
    setState(() {
      _eventos = eventos.where((e) => e.estado == 'activo').toList();
    });
  }*/
  Future<void> _cargarEventos() async {
    try {
      final eventos = await _eventRepo.obtenerEventosRemotos();
      if (!mounted) return;

      setState(() {
        _eventos = eventos.where((e) => e.estado == 'activo').toList();
      });
    } catch (e) {
      print('Error al cargar eventos: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los eventos !!!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _asignarEntrenador() async {
    if (selectedEventId == null || selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un evento y un entrenador')),
      );
      return;
    }

    final eventoId = int.parse(selectedEventId!);
    final trainerId = int.parse(selectedTrainerId!);

    if (_entrenadoresAsignados.contains(trainerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este entrenador ya fue asignado a este evento')),
      );
      return;
    }

    final success = await _assignmentRepo.asignarEntrenadorAEventoRemoto(trainerId, eventoId);

    if (success) {
      _entrenadoresAsignados.add(trainerId);

      final nombreEntrenador = _monitores.firstWhere(
        (trainer) => trainer.id_usuario == trainerId,
        orElse: () => UserModel(id_usuario: 0, nombre: 'Desconocido', email: '', rol: '', estado_monitor: ''),
      ).nombre;

      _nombresEntrenadoresAsignados.add(nombreEntrenador);
      selectedTrainerId = null;

      final continuar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Entrenador asignado'),
          content: const Text('¿Deseas asignar otro entrenador?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );

      if (continuar == true) {
        setState(() {});
      } else {
        final resumen = _nombresEntrenadoresAsignados.join('\n');

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Entrenadores Asignados'),
            content: Text(resumen),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssignmentSuccessPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: el entrenador ya estaba asignado en la base de datos')),
      );
    }
  }

  List<UserModel> _monitoresDisponibles() {
    return _monitores.where((m) => !_entrenadoresAsignados.contains(m.id_usuario)).toList();
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
                        color: const Color.fromARGB(255, 134, 134, 134),
                        icono: Icons.arrow_back,
                        ancho: 160,
                        alto: 50,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildEventoDropdown(),
                      const SizedBox(height: 20),
                      _buildTrainerDropdown(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            text: 'Asignar',
                            color: const Color(0xFF038C65),
                            ancho: 140,
                            alto: 50,
                            onPressed: _asignarEntrenador,
                          ),
                          ActionButton(
                            text: 'Regresar',
                            color: const Color.fromARGB(255, 134, 134, 134),
                            icono: Icons.arrow_back,
                            ancho: 160,
                            alto: 50,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminTrainerHomePage()),
                                (Route<dynamic> route) => false,
                              );
                            },
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
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Seleccionar evento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        value: selectedEventId,
        onChanged: (value) {
          setState(() {
            selectedEventId = value;
            _entrenadoresAsignados.clear();
            _nombresEntrenadoresAsignados.clear();
          });
        },
        validator: (value) => value == null ? 'Campo requerido' : null,
        items: _eventos.map((evento) {
          return DropdownMenuItem<String>(
            value: evento.id_evento.toString(),
            child: Text(evento.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrainerDropdown() {
    final disponibles = _monitoresDisponibles();

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar entrenador',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: selectedTrainerId,
      items: disponibles.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.id_usuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTrainerId = value;
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}

///Codigo de conexion local: ¡¡¡NO BORRAR!!!
/*
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

  final List<int> _entrenadoresAsignados = [];
  final List<String> _nombresEntrenadoresAsignados = [];

  String? selectedEventId;
  String? selectedTrainerId;

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

  Future<void> _asignarEntrenador() async {
    if (selectedEventId == null || selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un evento y un entrenador')),
      );
      return;
    }

    final eventoId = int.parse(selectedEventId!);
    final trainerId = int.parse(selectedTrainerId!);

    if (_entrenadoresAsignados.contains(trainerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este entrenador ya fue asignado a este evento')),
      );
      return;
    }

    final success = await _assignmentRepo.asignarEntrenadorAEvento(eventoId, trainerId);

    if (success) {
      _entrenadoresAsignados.add(trainerId);

      final nombreEntrenador = _monitores.firstWhere(
        (trainer) => trainer.id_usuario == trainerId,
        orElse: () => UserModel(id_usuario: 0, nombre: 'Desconocido', email: '',rol: '',estado_monitor: ''),
      ).nombre;

      _nombresEntrenadoresAsignados.add(nombreEntrenador);
      selectedTrainerId = null;

      final continuar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Entrenador asignado'),
          content: const Text('¿Deseas asignar otro entrenador?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );

      if (continuar == true) {
        setState(() {});
      } else {
        final resumen = _nombresEntrenadoresAsignados.join('\n');

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Entrenadores Asignados'),
            content: Text(resumen),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssignmentSuccessPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: el entrenador ya estaba asignado en la base de datos')),
      );
    }
  }

  List<UserModel> _monitoresDisponibles() {
    return _monitores.where((m) => !_entrenadoresAsignados.contains(m.id_usuario)).toList();
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
                        color: const Color.fromARGB(255, 134, 134, 134),
                        icono: Icons.arrow_back,
                        ancho: 160,
                        alto: 50,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildEventoDropdown(),
                      const SizedBox(height: 20),
                      _buildTrainerDropdown(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            text: 'Asignar',
                            color: const Color(0xFF038C65),
                            ancho: 140,
                            alto: 50,
                            onPressed: _asignarEntrenador,
                          ),
                          ActionButton(
                            text: 'Regresar',
                            color: const Color.fromARGB(255, 134, 134, 134),
                            icono: Icons.arrow_back,
                            ancho: 160,
                            alto: 50,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminTrainerHomePage()),
                                (Route<dynamic> route) => false,
                              );
                            },
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
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Seleccionar evento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        value: selectedEventId,
        onChanged: (value) {
          setState(() {
            selectedEventId = value;
            _entrenadoresAsignados.clear();
            _nombresEntrenadoresAsignados.clear();
          });
        },
        validator: (value) => value == null ? 'Campo requerido' : null,
        items: _eventos.map((evento) {
          return DropdownMenuItem<String>(
            value: evento.id_evento.toString(),
            child: Text(evento.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrainerDropdown() {
    final disponibles = _monitoresDisponibles();

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar entrenador',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: selectedTrainerId,
      items: disponibles.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.id_usuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTrainerId = value;
        });
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}*/