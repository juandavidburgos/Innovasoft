import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:basic_flutter/services/local_data_service.dart';
import 'package:flutter/material.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainerSelectEventPage extends StatefulWidget {
  const TrainerSelectEventPage({super.key});

  @override
  State<TrainerSelectEventPage> createState() => _TrainerSelectEventPageState();
}

class _TrainerSelectEventPageState extends State<TrainerSelectEventPage> {
  final EventRepository _eventRepo = EventRepository();

  String nombreUsuario = '';
  int usuarioId = -1;
  List<EventModel> eventosAsignados = [];
  EventModel? eventoSeleccionado;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosSesion();
    _sincronizarEventosConBackend();
  }

  Future<void> _cargarDatosSesion() async {
    final prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getInt('id_usuario') ?? -1;
    print('👤 ID del usuario logueado: $usuarioId');
  }


  Future<void> _sincronizarEventosConBackend() async {
    final contextRef = context; // evita usar context después de un await
    final conectado = await LocalDataService.db.hayInternet();

    if (conectado == false) {
      // Si no hay internet, solo carga local
      await _cargarEventosAsignadosLocales();
      print("NO HAY INTERNET");
      return;
    }else{
      print("HAY INTERNET");
    }

    _cargando = true;
    try {
      // Paso 1: Obtener eventos actualizados desde el backend
      final eventosActualizados = await _eventRepo.obtenerEventosAsignadosRemotos(usuarioId);
      print("🧾 Eventos recibidos del backend: ${eventosActualizados.length}");
      for (var e in eventosActualizados) {
        print("🟢 Evento → ID: ${e.id_evento}, nombre: ${e.nombre}");
      }

      // Paso 2: Guardar en base de datos local
      await _eventRepo.agregarListaDeEventos(eventosActualizados);
      await _eventRepo.agregarAsignaciones(eventosActualizados, usuarioId);
      print("✅ Asignaciones agregadas para usuario $usuarioId");


      final eventosLocales = await _eventRepo.obtenerEventosDelEntrenador(usuarioId);
      print('🔍 Eventos guardados localmente: ${eventosLocales.length}');

    } catch (e) {
      // Mostrar mensaje si ya estás en pantalla
      if (context.mounted) {
        ScaffoldMessenger.of(contextRef).showSnackBar(
          SnackBar(content: Text('Error al sincronizar eventos: $e')),
        );
      }
    } finally {
      _cargando = false;
    print("NO CARGO DEL BACK");
      // Paso 3: Siempre cargar lo local
      await _cargarEventosAsignadosLocales();
    }
  }

  Future<void> _cargarEventosAsignadosLocales() async {
    final eventos = await _eventRepo.obtenerEventosDelEntrenador(usuarioId);
    if (!mounted) return; // ✅ evita el error
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

Widget _buildDropdownEventos() {
    if (eventosAsignados.isEmpty) {
      return const Text(
        'No tienes eventos asignados.',
        style: TextStyle(fontSize: 16),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        child: DropdownButtonFormField<EventModel>(
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: eventosAsignados.contains(eventoSeleccionado) ? eventoSeleccionado : null,
          hint: const Text('Seleccionar evento'),
          selectedItemBuilder: (BuildContext context) {
            return eventosAsignados.map((evento) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  evento.nombre ?? 'Sin nombre',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList();
          },
          items: eventosAsignados.map((evento) {
            final fecha = evento.fecha_hora_inicio.toLocal().toIso8601String().substring(0, 10) ?? 'Sin fecha';
            return DropdownMenuItem<EventModel>(
              value: evento,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.nombre ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fecha: $fecha',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(color: Colors.grey, thickness: 0.5),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              eventoSeleccionado = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MainButton(
                      texto: 'Iniciar registro',
                      color: const Color(0xFF1A3E58),
                      onPressed: _iniciarRegistro,
                    ),
                  ),
                  const SizedBox(width: 10), // espacio entre botones
                  Expanded(
                    child: ActionButton(
                      text: 'Regresar',
                      color: const Color.fromARGB(255, 134, 134, 134),
                      icono: Icons.arrow_back,
                      ancho: 160, // Este valor será ignorado si usas Expanded
                      alto: 50,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/trainer_home');
                      },
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: ActionButton(
                  icono: Icons.sync,
                  color: Colors.green,
                  text: 'Actualizar eventos',
                  alto: 50,
                  onPressed: _sincronizarEventosConBackend,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

}

