import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:flutter/material.dart';
import '../../repositories/assignment_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/event_repository.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
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
  final EventRepository _eventRepo = EventRepository();

  List<UserModel> _monitores = [];
  List<EventModel> _todosEventos = [];

  String? selectedMonitorId;
  List<String?> eventosAsignadosIds = [];

  @override
  void initState() {
    super.initState();
    _cargarMonitores();
    _cargarTodosLosEventos();
  }

  Future<void> _cargarMonitores() async {
    try {
      final usuarios = await _userRepo.obtenerUsuariosRemotos();
      setState(() {
        _monitores = usuarios
            .where((u) => u.rol == 'Monitor' && u.estado_monitor == 'activo')
            .toList();
      });
    } catch (e) {
      print('Error al cargar monitores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar los monitores'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  //local
  /*Future<void> _cargarMonitores() async {
    final usuarios = await _userRepo.obtenerUsuarios();
    setState(() {
      _monitores = usuarios.where((u) => u.rol == 'Monitor').toList();
    });
  }*/

  Future<void> _cargarTodosLosEventos() async {
    try {
      final eventos = await _eventRepo.obtenerEventosRemotos();
      final eventosActivos = eventos.where((evento) => evento.estado == 'activo').toList();
      setState(() {
        _todosEventos = eventosActivos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al obtener eventos desde el servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  //local
  /*Future<void> _cargarTodosLosEventos() async {
    final eventos = await _eventRepo.obtenerEventos();
    final eventosActivos = eventos.where((evento) => evento.estado == 'activo').toList();
    setState(() {
      _todosEventos = eventosActivos;
    });
  }*/

  Future<void> _cargarEventosAsignados(String monitorId) async {
    //local
    final eventosAsignados = await _assignmentRepo.obtenerEventosDelMonitor(int.parse(monitorId));
    //desde el backend
    //final eventosAsignados = await _assignmentRepo.getEventosAsignados(int.parse(monitorId));
    setState(() {
      eventosAsignadosIds = eventosAsignados.map<String?>((e) => e.id_evento.toString()).toList();
    });
  }

  Future<void> _actualizarAsignacion() async {
    if (selectedMonitorId == null || eventosAsignadosIds.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un monitor y todos los eventos')),
      );
      return;
    }

    final idUsuario = int.parse(selectedMonitorId!);

    List<EventModel> eventosAsignadosAnteriores;
    try {
      eventosAsignadosAnteriores = await _assignmentRepo.getEventosAsignados(idUsuario);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión con el servidor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevosEventos = eventosAsignadosIds.map((id) => int.parse(id!)).toList();

    bool exitoGlobal = true;

    for (int i = 0; i < eventosAsignadosAnteriores.length; i++) {
      final int? anteriorNullable = eventosAsignadosAnteriores[i].id_evento;
      if (anteriorNullable == null) {
        // Opcional: puedes mostrar un SnackBar o simplemente saltar esta iteración
        continue;
      }
      final int anterior = anteriorNullable;
      final int nuevo = nuevosEventos[i];

      if (anterior != nuevo) {
        final result = await _assignmentRepo.modificarAsignacionEntrenadorRemoto(
          idUsuario,
          anterior,
          nuevo,
        );

        if (!result) {
          exitoGlobal = false;
          break;
        }
      }
    }

    if (exitoGlobal) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentSuccessPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentErrorPage()),
      );
    }
  }

  //proceso local
  /*Future<void> _actualizarAsignacion() async {
    if (selectedMonitorId == null || eventosAsignadosIds.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un monitor y todos los eventos')),
      );
      return;
    }

    final result = await _assignmentRepo.actualizarEventosDeMonitor(
      int.parse(selectedMonitorId!),
      eventosAsignadosIds.map((id) => int.parse(id!)).toList(),
    );

    if (result) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentSuccessPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditAssignmentErrorPage()),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final bool sinDatos = _monitores.isEmpty || _todosEventos.isEmpty;

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
                const Text('Editar Asignación de Eventos a Monitores', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                sinDatos
                  ? Column(
                      children: [
                        const Text(
                          'No hay monitores o eventos disponibles',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ActionButton(
                          text: 'Regresar',
                          color: const Color.fromARGB(255, 134, 134, 134),
                          icono: Icons.arrow_back,
                          ancho: 160,
                          alto: 50,
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => AdminTrainerHomePage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    )
                  : 
                  Column(
                    children: [
                      _buildMonitorDropdown(),
                      const SizedBox(height: 20),
                      for (int i = 0; i < eventosAsignadosIds.length; i++) ...[
                        _buildEventoDropdown(i),
                        const SizedBox(height: 15),
                      ],
                      const SizedBox(height: 30),
                      MainButton(
                        texto: 'Actualizar asignaciones',
                        color: Color(0xFF038C65),
                        onPressed: _actualizarAsignacion,
                      ),
                      const SizedBox(height: 15),
                      ActionButton(
                            text: 'Regresar',
                            color: Color.fromARGB(255, 134, 134, 134),
                            icono: Icons.arrow_back,
                            ancho: 160,
                            alto: 50,
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
          ),
        ),
      ),
    );
  }

  Widget _buildMonitorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar monitor',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: selectedMonitorId,
      items: _monitores.map((monitor) {
        return DropdownMenuItem<String>(
          value: monitor.id_usuario.toString(),
          child: Text(monitor.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMonitorId = value;
        });
        if (value != null) {
          _cargarEventosAsignados(value);
        }
      },
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildEventoDropdown(int index) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Evento asignado ${index + 1}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: eventosAsignadosIds[index],
      items: _todosEventos.map((evento) {
        return DropdownMenuItem<String>(
          value: evento.id_evento.toString(),
          child: Text(evento.nombre), 
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          eventosAsignadosIds[index] = value ?? "";
        });
      },
      validator: (value) => value == null || value == "" ? 'Campo requerido' : null,
    );
  }
}

/* Codigo antiguoi: NO BORRAR!!! */

/*class EditTrainerAssignmentPage extends StatefulWidget {
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
      _monitores = usuarios.where((u) => u.rol == 'Monitor').toList();
    });
  }

  Future<void> _cargarEntrenadoresDeEvento(String eventoId) async {
    final entrenadores = await _assignmentRepo.obtenerEntrenadoresPorEvento(int.parse(eventoId));
    setState(() {
      selectedTrainerIds = entrenadores.map((e) => e['id_usuario'].toString()).toList();
      trainerCount = selectedTrainerIds.length;
    });
  }

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
    return _monitores.where((m) => !idsSeleccionados.contains(m.id_usuario.toString())).toList();
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
          value: monitor.id_usuario.toString(),
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
}*/