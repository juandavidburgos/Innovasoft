import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/repositories/register_repository.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/models/event_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';


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

    Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitud = posicion.latitude;
      longitud = posicion.longitude;
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
      appBar: AppBar(title: const Text('Registro final')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $nombreUsuario'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _obtenerUbicacion,
              child: const Text('Registrar ubicación'),
            ),
            if (latitud != null && longitud != null)
              Text('Ubicación: ($latitud, $longitud)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargarImagen,
              child: const Text('Cargar imagen grupal'),
            ),
            if (pathImagen != null) Text('Imagen: $pathImagen'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _guardarReporte(),
              child: const Text('Enviar reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
