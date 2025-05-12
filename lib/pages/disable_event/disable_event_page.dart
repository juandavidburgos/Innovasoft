import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- Importación necesaria
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';
import 'confirm_disable_page.dart';
import 'error_disable_page.dart';
import '../home/admin_home_page.dart';

/// Página para seleccionar uno o varios eventos que se desean deshabilitar.
/// Solo se muestran los eventos con estado "activo".
class DisableEventPage extends StatefulWidget {
  const DisableEventPage({super.key});

  @override
  State<DisableEventPage> createState() => _DisableEventPageState();
}

class _DisableEventPageState extends State<DisableEventPage> {
  final EventRepository _repo = EventRepository();
  final List<int> _selectedEventIds = [];
  List<EventModel> _activeEvents = [];

  @override
  void initState() {
    super.initState();
    _loadActiveEvents();
  }

  /// Carga los eventos con estado "activo" desde el repositorio.
  void _loadActiveEvents() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _activeEvents = eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  /// Redirige a la página de confirmación con los IDs seleccionados.
  void _goToConfirmPage() {
    if (_selectedEventIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un evento para continuar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmDisablePage(idsEventos: _selectedEventIds),
        ),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ErrorDisablePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo_indeportes.png',
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '"Indeportes somos todos"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deshabilitar Evento",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Selecciona los eventos a deshabilitar:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _activeEvents.length,
                        itemBuilder: (context, index) {
                          final evento = _activeEvents[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(
                                evento.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${evento.ubicacion} - '
                                '${dateFormat.format(evento.fechaHoraInicio)} a '
                                '${dateFormat.format(evento.fechaHoraFin)}',
                              ),
                              value: _selectedEventIds.contains(evento.idEvento),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedEventIds.add(evento.idEvento!);
                                  } else {
                                    _selectedEventIds.remove(evento.idEvento);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(
                        text: 'VOLVER',
                        color: Color(0xFF1D5273),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminHomePage(),
                          ),
                        ),
                      ),
                      ActionButton(
                        text: 'CONTINUAR',
                        color: Color(0xFF038C65),
                        onPressed: _goToConfirmPage,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';
import 'confirm_disable_page.dart';
import 'error_disable_page.dart';
import '../home/admin_home_page.dart';

/// Página para seleccionar uno o varios eventos que se desean deshabilitar.
/// Solo se muestran los eventos con estado "activo".
class DisableEventPage extends StatefulWidget {
  const DisableEventPage({super.key});

  @override
  State<DisableEventPage> createState() => _DisableEventPageState();
}

class _DisableEventPageState extends State<DisableEventPage> {
  final EventRepository _repo = EventRepository();
  final List<int> _selectedEventIds = [];
  List<EventModel> _activeEvents = [];

  @override
  void initState() {
    super.initState();
    _loadActiveEvents();
  }

  /// Carga los eventos con estado "activo" desde el repositorio.
  void _loadActiveEvents() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _activeEvents = eventos.where((e) => e.estado == 'activo').toList();
    });
  }

  /// Redirige a la página de confirmación con los IDs seleccionados.
  void _goToConfirmPage() {
    if (_selectedEventIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un evento para continuar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1), // <- Hace que no se pegue abajo
        ),
      );
      return;
    }

    try{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmDisablePage(idsEventos: _selectedEventIds),
        ),
      );
    }catch (e){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ErrorDisablePage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/indeportes_logo.png', // <- Asegúrate de poner el logo aquí
                  width: 200,
                ),
                const SizedBox(height: 10),
                const Text(
                  '"Indeportes somos todos"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Deshabilitar Evento",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selecciona los eventos a deshabilitar:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 350, // <- Altura fija del mini cuadro
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Scrollbar( // <- Opcional: para que se vea la barra de scroll
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _activeEvents.length,
                      itemBuilder: (context, index) {
                        final evento = _activeEvents[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(
                              evento.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${evento.ubicacion} - ${evento.fecha.toLocal().toString().split(' ')[0]}',
                            ),
                            value: _selectedEventIds.contains(evento.idEvento),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEventIds.add(evento.idEvento!);
                                } else {
                                  _selectedEventIds.remove(evento.idEvento);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //BOTONES
                const SizedBox(height: 10), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(
                            text: 'VOLVER',
                            color: Colors.blue,
                            onPressed: () => Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const AdminHomePage()),),
                      ),
                      ActionButton(
                        text: 'CONTINUAR',
                        color: Colors.green,
                        onPressed: _goToConfirmPage,  
                      ),
                      const SizedBox(height: 20),
                    ]
                  ),
                  // <- Añade esto debajo para separarlos del final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
