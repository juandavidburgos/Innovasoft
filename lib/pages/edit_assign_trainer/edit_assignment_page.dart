import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:flutter/material.dart';
import '../../repositories/assignment_repository.dart';
import '../../repositories/user_repository.dart';
import '../../models/user_model.dart';
import '../widgets/action_button.dart';
import 'edit_assignmen_success_page.dart';
import 'edit_assignmen_error_page.dart';
import '../home/admin_trainer_home_page.dart';

class EditTrainerAssignmentPage extends StatefulWidget {
  const EditTrainerAssignmentPage({super.key});

  @override
  State<EditTrainerAssignmentPage> createState() => _EditTrainerAssignmentPageState();
}

class _EditTrainerAssignmentPageState extends State<EditTrainerAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final AssignmentRepository _assignmentRepo = AssignmentRepository();
  final UserRepository _userRepo = UserRepository();

  List<Map<String, dynamic>> _eventosAsignados = [];
  List<UserModel> _monitores = [];

  String? selectedEventId;
  int trainerCount = 0;
  List<String?> selectedTrainerIds = [];

  @override
  void initState() {
    super.initState();
    _cargarEventosConAsignaciones();
    _cargarMonitores();
  }

  Future<void> _cargarEventosConAsignaciones() async {
    final eventos = await _assignmentRepo.obtenerAsignacionesConNombreEvento();
    setState(() {
      _eventosAsignados = eventos;
    });
  }

  Future<void> _cargarMonitores() async {
    final usuarios = await _userRepo.obtenerUsuarios();
    setState(() {
      _monitores = usuarios.where((u) => u.rol == 'ENTRENADOR').toList();
    });
  }

  Future<void> _cargarEntrenadoresDeEvento(String eventoId) async {
    final entrenadores = await _assignmentRepo.obtenerEntrenadoresPorEvento(int.parse(eventoId));
    setState(() {
      selectedTrainerIds = entrenadores.map((e) => e['id_usuario'].toString()).toList();
      trainerCount = selectedTrainerIds.length;
    });
  }

  /*Future<void> _actualizarAsignacion() async {
    if (selectedEventId == null || selectedTrainerIds.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona evento y todos los entrenadores')),
      );
      return;
    }

    final ids = selectedTrainerIds.map((id) => int.parse(id!)).toList();
    final result = await _assignmentRepo.actualizarAsignacionesDeEvento(
      int.parse(selectedEventId!),
      ids,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'Asignaciones actualizadas' : 'Ocurrió un error al actualizar'),
      ),
    );

    if (result) {
      // Navegar de vuelta y empujar la pantalla de nuevo
      Navigator.pop(context); // Regresar a la página anterior
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EditTrainerAssignmentPage(),
        ),
      );
    }
  }*/

  Future<void> _actualizarAsignacion() async {
    if (selectedEventId == null || selectedTrainerIds.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona evento y todos los entrenadores')),
      );
      return;
    }

    final ids = selectedTrainerIds.map((id) => int.parse(id!)).toList();
    final result = await _assignmentRepo.actualizarAsignacionesDeEvento(
      int.parse(selectedEventId!),
      ids,
    );

    if (result) {
      // Si se actualizó correctamente, mostrar pantalla de éxito
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentSuccessPage()),
      );
    } else {
      // Si falló la actualización, mostrar pantalla de error
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentErrorPage()),
      );
    }
  }

  List<UserModel> _monitoresDisponiblesPara(int index) {
    final idsSeleccionados = selectedTrainerIds.where((id) => id != null && selectedTrainerIds.indexOf(id) != index).toSet();
    return _monitores.where((m) => !idsSeleccionados.contains(m.idUsuario.toString())).toList();
  }

  void _agregarEntrenador() {
    setState(() {
      selectedTrainerIds.add(""); // Cambiar de null a una cadena vacía como valor predeterminado
      trainerCount++; // Aumentar el contador de entrenadores
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool sinEventos = _eventosAsignados.isEmpty || _monitores.isEmpty;

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
                const Text('Editar Asignación de Entrenadores', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                if (sinEventos)
                  const Text('No hay eventos con entrenadores asignados o no hay entrenadores disponibles', style: TextStyle(color: Colors.red))
                else
                  Column(
                    children: [
                      _buildEventoDropdown(),
                      const SizedBox(height: 20),
                      for (int i = 0; i < trainerCount; i++) ...[
                        _buildTrainerDropdown(i),
                        const SizedBox(height: 15),
                      ],
                      MainButton(
                        texto: 'Agregar un entrenador más',
                        color: Color(0xFF1A3E58),
                        onPressed: _agregarEntrenador,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MainButton(
                            texto: 'Actualizar',
                            color: Color(0xFF038C65),
                            onPressed: _actualizarAsignacion,
                          ),
                          ActionButton(
                            text: 'Regresar',
                            color: Color.fromARGB(255, 134, 134, 134),
                            icono: Icons.arrow_back,
                            ancho: 145,
                            alto: 48,
                            //onPressed: () => Navigator.pop(context),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => AdminTrainerHomePage()),
                                (Route<dynamic> route) => false, // elimina todas las rutas anteriores
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
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar evento asignado',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _eventosAsignados.map((evento) {
        return DropdownMenuItem<String>(
          value: evento['id_evento'].toString(),
          child: Text(evento['nombre']),
        );
      }).toList(),
      value: selectedEventId,
      onChanged: (value) {
        setState(() {
          selectedEventId = value;
        });
        if (value != null) {
          _cargarEntrenadoresDeEvento(value);
        }
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
      value: selectedTrainerIds[index] == "" ? null : selectedTrainerIds[index], // Cambiar a null si está vacío
      items: disponibles.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.idUsuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTrainerIds[index] = value ?? "";
        });
      },
      validator: (value) => value == null || value == "" ? 'Campo requerido' : null,
    );
  }
}
