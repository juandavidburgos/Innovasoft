import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/repositories/register_repository.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/models/event_model.dart';
import 'package:basic_flutter/models/user_model.dart';
import 'package:basic_flutter/models/report_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';





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
  String rol ='';
  String email = '';
  double? latitud;
  double? longitud;
  String? pathImagen;
  String? coordenadas;
  bool ubicacionRegistrada = false;

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
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      usuarioId = prefs.getInt('usuarioId') ?? 0;
      nombreUsuario = prefs.getString('nombreUsuario') ?? 'Desconocido';
      rol = prefs.getString('rolUsuario') ?? 'Sin rol';
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
      coordenadas = '($latitud,$longitud)';
      ubicacionRegistrada = true;
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
      titulo: 'Registro ${evento.nombre}',
      descripcion: 'Formulario de asistentes a ${evento.nombre}',
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
        preguntaId: entry.key.hashCode,
        contenido: entry.value.toString(),
        formularioId: formulario.idFormulario!,
      ));
    }).toList();

    // Guardar localmente
    await RegisterRepository().guardarFormularioCompleto(
      formulario: formulario,
      respuestas: respuestas,
    );

    // Construir el reporte completo
    final reporte = Reporte(
      evento: EventModel(
        nombre: evento.nombre,
        descripcion: evento.descripcion ?? 'Sin descripción',
        ubicacion: evento.ubicacion,
        fechaHoraInicio: evento.fechaHoraInicio,
        fechaHoraFin: evento.fechaHoraFin,
      ),
      usuario: UserModel(
        idUsuario: usuarioId,
        nombre: nombreUsuario ?? 'Desconocido',
        rol: rol ?? 'Sin rol',
        email: email,
      ),
      asistentes: widget.asistentes,
    );

    // Imprimir reporte JSON (simulando envío)
    print('📦 Reporte JSON:');
    print(jsonEncode(reporte.toJson()));

    // Si luego deseas enviarlo:
    // await http.post(..., body: jsonEncode(reporte.toJson()));

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

            Expanded(
              flex: 2,
              child: widget.asistentes.isEmpty
                  ? const Center(child: Text('No hay asistentes registrados.'))
                  : ListView.builder(
                      itemCount: widget.asistentes.length,
                      itemBuilder: (context, index) {
                        final asistente = widget.asistentes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${asistente['nombres']} ${asistente['apellidos']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('ID: ${asistente['identificacion']}'),
                                Text('Edad: ${asistente['edad']}'),
                                Text('Género: ${asistente['genero']}'),
                                Text('Municipio: ${asistente['municipio']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            // Botones finales (ubicación, imagen, reporte)
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _obtenerUbicacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3E58),
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Cambia el valor a tu gusto
                    ),
                  ),
                  icon: Icon(
                    ubicacionRegistrada ? Icons.check_circle_outline : Icons.location_city,
                    color: Colors.white,
                  ),
                  label: Text(
                    ubicacionRegistrada ? 'Actualizar ubicación' : 'Registrar ubicación',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                if (coordenadas != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Coordenadas: $coordenadas', style: const TextStyle(fontSize: 14)),
                  ),
                const SizedBox(height: 20),
                _buildStyledButton('Cargar imagen grupal', const Color(0xFF1A3E58), _cargarImagen, Icons.upload),
                if (pathImagen != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Imagen: $pathImagen', style: const TextStyle(fontSize: 14)),
                  ),
                const SizedBox(height: 30),
                _buildStyledButton('Enviar reporte', const Color(0xFF00944C), _guardarReporte, Icons.save),
              ],
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
