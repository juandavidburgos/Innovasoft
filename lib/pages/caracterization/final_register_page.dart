import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/repositories/forms_repository.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/models/event_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';





/*class FinalRegisterPage extends StatefulWidget {
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
  String estado_monitor = '';
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

  //Funcion de cargar sesion para simularicion
  Future<void> _cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      //usuarioId = prefs.getInt('usuarioId') ?? 0;
      nombreUsuario = prefs.getString('nombre') ?? 'Desconocido';
      rol = prefs.getString('rol') ?? 'Sin rol';
      email = prefs.getString('email') ?? 'Desconocido';
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
      id_formulario: DateTime.now().millisecondsSinceEpoch,
      titulo: 'Registro ${evento.nombre}',
      descripcion: 'Formulario de asistentes a ${evento.nombre}',
      fecha_creacion: DateTime.now(),
      id_evento: evento.id_evento,
      id_usuario: usuarioId,
      latitud: latitud,
      longitud: longitud,
      path_imagen: pathImagen,
    );

    final respuestas = widget.asistentes.expand((asistente) {
      return asistente.entries.map((entry) => AnswerModel(
        id_respuesta: DateTime.now().millisecondsSinceEpoch + entry.key.hashCode,
        pregunta_id: entry.key.hashCode,
        contenido: entry.value.toString(),
        formulario_id: formulario.id_formulario!,
        id_evento:evento.id_evento!,
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
        fecha_hora_inicio: evento.fecha_hora_inicio,
        fecha_hora_fin: evento.fecha_hora_fin,
      ),
      usuario: UserModel(
        id_usuario: usuarioId,
        nombre: nombreUsuario ?? 'Desconocido',
        rol: rol ?? 'Sin rol',
        email: email,
        estado_monitor: estado_monitor,
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


}*/

class FinalRegisterPage extends StatefulWidget {
  final EventModel evento;
  final int usuario_id;
  final int formulario_id;

  const FinalRegisterPage({
    required this.evento,
    required this.usuario_id,
    required this.formulario_id,
    super.key,
  });

  @override
  State<FinalRegisterPage> createState() => _FinalRegisterPageState();
}

class _FinalRegisterPageState extends State<FinalRegisterPage> {
  double? latitud;
  double? longitud;
  String? pathImagen;

  final FormsRepository _repo = FormsRepository();

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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pathImagen = pickedFile.path;
      });
    }
  }

  Future<void> _enviarFormularioUbicacion() async {
    if (latitud == null || longitud == null) {
      _mostrarMensaje('Debe registrar la ubicación.');
      return;
    }

    if (pathImagen == null) {
      _mostrarMensaje('Debe subir una imagen grupal.');
      return;
    }

    


    final form = FormModel(
      id_formulario: widget.formulario_id,
      id_evento: widget.evento.id_evento,
      id_usuario: widget.usuario_id,
      titulo: 'Evidencia final',
      descripcion: 'Ubicación e imagen grupal',
      fecha_creacion: DateTime.now(),
      latitud: latitud,
      longitud: longitud,
      path_imagen: pathImagen,
    );

    final conectado = await _repo.hayConexion();

    if (conectado) {
      final enviado = await _repo.enviarEvidenciaEntrenador(form);
      if (!enviado) {
        await _repo.guardarEvidenciaEnColaPeticiones(form); // 👈 guardar localmente si falla
      }
    } else {
      await _repo.guardarEvidenciaEnColaPeticiones(form);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte final procesado correctamente')),
    );

    // Esperar un segundo antes de redirigir (opcional)
    await Future.delayed(const Duration(seconds: 1));

    // Redirigir a /trainer_home (elimina historial de navegación)
    Navigator.pushNamedAndRemoveUntil(context, '/trainer_home', (route) => false);

  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro de comprobación',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center( // Centra todo el contenido en la pantalla
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MainButton(
                texto: 'Registrar ubicación actual',
                color: const Color(0xFF1A3E58),
                icono: Icons.location_city_rounded,
                onPressed: _obtenerUbicacion,
              ),
              const SizedBox(height: 20),
              MainButton(
                texto: 'Cargar imagen grupal',
                color: const Color(0xFF1A3E58),
                icono: Icons.upload,
                onPressed: _cargarImagen,
              ),
              const SizedBox(height: 20),

              if (latitud != null && longitud != null)
                Text(
                  'Ubicación registrada:\nLatitud: $latitud\nLongitud: $longitud',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

              const SizedBox(height: 12),

              if (pathImagen != null)
                Column(
                  children: [
                    const Text('Imagen grupal seleccionada:'),
                    const SizedBox(height: 8),
                    Image.file(
                      File(pathImagen!),
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              MainButton(
                texto: 'Enviar Reporte',
                color: Colors.green,
                icono: Icons.send,
                onPressed: _enviarFormularioUbicacion,
              ),
            ],
          ),
        ),
      ),
    );
  }


}

