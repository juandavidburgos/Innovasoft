import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/repositories/register_repository.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/models/event_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';



class FinalRegisterPage extends StatefulWidget {
  final List<Map<String, dynamic>> asistentes;
  final EventModel evento;

  const FinalRegisterPage({
    super.key,
    required this.asistentes,
    required this.evento,
  });

  @override
  State<FinalRegisterPage> createState() => FinalRegisterPageState();
}

class FinalRegisterPageState extends State<FinalRegisterPage> {
  final ImagePicker _picker = ImagePicker();

  String nombreUsuario = '';
  int usuarioId = 0;
  double? latitud;
  double? longitud;
  String? pathImagen;
  String? ubicacionNombre;

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }
/*
  Future<void> _cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final nombre = prefs.getString('nombreUsuario');
    final id = prefs.getInt('idUsuario');

    if (nombre != null && id != null) {
      setState(() {
        nombreUsuario = nombre;
        usuarioId = id;
      });
    } else {
      // Si no hay datos guardados, redirige a login o muestra error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión no encontrada. Inicie sesión.')),
      );
      // Puedes usar: Navigator.pushReplacementNamed(context, '/login');
    }
  }
  */
  //Funcion de cargar sesion para simularicion
  Future<void> _cargarSesion() async {
    // Simulación: reemplaza con SharedPreferences o SessionService
    setState(() {
      nombreUsuario = 'Carlos Ramírez';
      usuarioId = 1; // Debe venir de sesión real
    });
  }


  Future<void> _obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa el GPS.')),
      );
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado.')),
        );
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso denegado permanentemente.')),
      );
      return;
    }

    // Obtener coordenadas
    Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Geocodificación inversa
    List<Placemark> placemarks = await placemarkFromCoordinates(
      posicion.latitude,
      posicion.longitude,
    );

    Placemark lugar = placemarks.first;

    setState(() {
      latitud = posicion.latitude;
      longitud = posicion.longitude;
      ubicacionNombre = '${lugar.locality}, ${lugar.administrativeArea}'; // ej. Popayán, Cauca
    });
  }

  Future<void> _cargarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        pathImagen = imagen.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
      );
    }
  }

  Future<void> _guardarReporte() async {
    final evento = widget.evento;

    final formulario = FormModel(
      idFormulario: DateTime.now().millisecondsSinceEpoch,
      titulo: 'Registro evento ${evento.nombre}',
      descripcion: 'Formulario de asistentes al evento ${evento.nombre}',
      fechaCreacion: DateTime.now(),
      eventoId: evento.idEvento,
      usuarioId: usuarioId,
      latitud: latitud,
      longitud: longitud,
      pathImagen: pathImagen,
    );

    final respuestas = widget.asistentes.expand((asistente) {
      return asistente.entries.map((entry) => AnswerModel(
            id: DateTime.now().millisecondsSinceEpoch + entry.key.hashCode,
            preguntaId: int.tryParse(entry.key) ?? 0,
            contenido: entry.value.toString(),
            formularioId: formulario.idFormulario!,
          ));
    }).toList();

    await RegisterRepository().guardarFormularioCompleto(
      formulario: formulario,
      respuestas: respuestas,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario guardado localmente')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro de comprobación',
          style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 30),

            Text(
              'Usuario: $nombreUsuario',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 30),

            // Bloque central centrado vertical y horizontalmente
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStyledButton('Registrar mi ubicación', const Color(0xFF1A3E58), _obtenerUbicacion, Icons.location_city),
                    if (ubicacionNombre != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Coordenadas: ($latitud, $longitud) \n Ubicación: $ubicacionNombre', style: const TextStyle(fontSize: 14)),
                      ),
                    const SizedBox(height: 30),
                    _buildStyledButton('Cargar imagen grupal', const Color(0xFF1A3E58), _cargarImagen, Icons.upload),
                    if (pathImagen != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Imagen: $pathImagen', style: const TextStyle(fontSize: 14)),
                      ),
                    const SizedBox(height: 60),
                    _buildStyledButton('Enviar reporte', const Color(0xFF00944C), _guardarReporte, Icons.save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),


    );
  }

  Widget _buildStyledButton(String text, Color color, VoidCallback onPressed, IconData icono) {
    return MainButton(
      onPressed: onPressed,
      color: color,
      texto:text,
      ancho:250,
      alto:60,
      icono: icono,
    );
  }


}
