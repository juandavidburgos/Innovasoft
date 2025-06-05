import 'package:basic_flutter/repositories/forms_repository.dart';
import 'package:basic_flutter/repositories/register_repository.dart';
import 'package:basic_flutter/services/local_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'final_register_page.dart';
import 'package:basic_flutter/models/event_model.dart'; // importa tu modelo
import 'package:basic_flutter/models/answer_model.dart';
import 'package:basic_flutter/models/form_model.dart';
import 'package:basic_flutter/models/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssistenceRegisterPage extends StatefulWidget {
  final EventModel evento;

  const AssistenceRegisterPage({super.key, required this.evento});

  @override
  State<AssistenceRegisterPage> createState() => _AssistenceRegisterPageState();
}

class _AssistenceRegisterPageState extends State<AssistenceRegisterPage> {
  final FormsRepository _repo = FormsRepository();

  int? id_usuario;
  int? formulario_id;
  List<QuestionModel> _preguntas = [];

  final _formKey = GlobalKey<FormState>();
  final Map<int, dynamic> _formData = {};
  final List<Map<int, dynamic>> _asistentes = [];
  DateTime? _fechaNacimiento;
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final RegisterRepository _registerRepo = RegisterRepository();

  @override
  void initState() {
    super.initState();
    _cargarSesion();
    _cargarPreguntas();
  }


  Future<void> _cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    id_usuario = prefs.getInt('id_usuario');
  }

  Future<void> _cargarPreguntas() async {
    final prefs = await SharedPreferences.getInstance();
    id_usuario = prefs.getInt('id_usuario');

    if (id_usuario == null || widget.evento.id_evento == null) return;

    // 🔍 Log de depuración para ver todos los formularios locales
    final formulariosLocales = await LocalDataService.db.getForms();
    for (var f in formulariosLocales) {
      print("📋 Formulario → ID: ${f.id_formulario}, evento: ${f.id_evento}, usuario: ${f.id_usuario}");
    }

    // Y para saber cuál es la combinación actual
    print("🔎 Buscando formulario con usuario: $id_usuario y evento: ${widget.evento.id_evento}");


    final formularioId = await _registerRepo.obtenerFormularioId(
      id_usuario!,
      widget.evento.id_evento!,
    );

    if (formularioId == null) {
      print('❌ No se encontró formulario para usuario: $id_usuario y evento: ${widget.evento.id_evento}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No se encontró el formulario asignado a este evento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    formulario_id = formularioId;
    print('🔎 Buscando preguntas del formulario ID: $formularioId');

    final preguntas = await _registerRepo.obtenerPreguntasPorFormulario(formularioId);

    setState(() {
      _preguntas = preguntas;
    });
  }

  void _actualizarEdad(DateTime fecha) {
    final edad = DateTime.now().year - fecha.year;
    _edadController.text = edad.toString();
    setState(() {
      _formData[5] = DateFormat('dd-MM-yyyy').format(fecha); // ← fecha de nacimiento 
      _formData[6] = edad;
    });
  }

  Future<void> _seleccionarFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _fechaNacimiento = picked;
      _fechaController.text = DateFormat('dd-MM-yyyy').format(picked);
      _actualizarEdad(picked);
    }
  }

  Widget _buildTextField(String label, int preguntaId,
      {bool obligatorio = false,
      TextEditingController? controller,
      TextInputType? tipo = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: tipo,
      validator: (value) {
        if (obligatorio && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }

        // Validaciones personalizadas según el id
        switch (preguntaId) {
          case 3: // DOCUMENTO IDENTIDAD
            if (value != null && (value.length < 8 || value.length > 10)) {
              return 'Debe tener entre 8 y 10 dígitos';
            }
            break;
          case 25: // TELÉFONO o CORREO
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }

            // Validar si es numérico (teléfono)
            if (RegExp(r'^\d+$').hasMatch(value)) {
              if (value.length < 10) {
                return 'Ingrese un teléfono válido (mínimo 10 dígitos)';
              }
            } else {
              // Validar si es correo electrónico
              if (value.contains(' ')) {
                return 'El correo no debe contener espacios';
              }
              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                return 'Ingrese un correo válido';
              }
            }
            break;
          case 9: // MESES EMBARAZO
          case 21: // AÑOS DE EXPERIENCIA
          case 6: // EDAD
            if (value != null && !RegExp(r'^\d+$').hasMatch(value)) {
              return 'Ingrese solo números';
            }
            break;
        }

        return null;
      },
      onSaved: (value) => _formData[preguntaId] = value,
    );
  }


  Widget _buildDropdown(String label, int preguntaId, List<String> opciones,
      {bool obligatorio = false}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) => _formData[preguntaId] = value,
      validator: (value) {
        if (obligatorio && (value == null || value.isEmpty)) {
          return 'Seleccione una opción';
        }
        return null;
      },
    );
  }

  void _finalizarRegistro() async {
    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid) {
      _formKey.currentState!.save();
      _asistentes.add(Map<int, dynamic>.from(_formData));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asistente actual registrado.')),
      );
    }

    final hayFormulariosGuardados = await _repo.hayFormulariosRegistrados();

    if (!hayFormulariosGuardados) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar al menos un asistente antes de continuar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Mostrar el cuadro de diálogo
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('¿Desea registrar otro asistente?'),
          content: const Text('Si selecciona "No", continuará al siguiente paso.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Registrar otro
              child: const Text('Sí'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false), // Continuar
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (continuar == false) {
      // Validación de seguridad
      if (_asistentes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe registrar al menos un asistente antes de continuar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }


      // Ir a la vista final
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalRegisterPage(
            evento: widget.evento,
            usuario_id: id_usuario!,
            formulario_id: formulario_id!,
          ),
        ),
      );
    } else {
      // El usuario desea registrar otro asistente → limpiar formulario
      _formKey.currentState!.reset();
      _formData.clear();
      _fechaController.clear();
      _edadController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario listo para otro asistente.')),
      );
    }
    // Si continuar == true, simplemente se queda en la misma página
  }


List<AnswerModel> _crearRespuestasDesdeFormulario(int idFormulario) {
  return _formData.entries.map((entry) {
    return AnswerModel(
      pregunta_id: entry.key,
      formulario_id: idFormulario,
      contenido: entry.value?.toString() ?? '',
      id_evento: widget.evento.id_evento!,
    );
  }).toList();
}

  void _guardarAsistente() async {
    if (!_formKey.currentState!.validate()) return;

    if (formulario_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el formulario asignado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    final respuestas = _crearRespuestasDesdeFormulario(formulario_id!);
    final conectado = await _repo.hayConexion();

    final enviado = conectado
      ? await _repo.enviarRespuestasFormulario(formulario_id!, widget.evento.id_evento!, respuestas)
      : await LocalDataService.db.guardarEnColaPeticionesSoloRespuestas(formulario_id!, widget.evento.id_evento!, respuestas);

    if (!enviado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Asistente guardado localmente. Se enviará cuando haya conexión.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Asistente registrado exitosamente.')),
      );
    }

    _formKey.currentState!.reset();
    _formData.clear();
    _fechaController.clear();
    _edadController.clear();
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }


  Widget _buildStyledButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text(
        'Registro de asistencia',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A3E58),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Formulario de asistencia',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
          ..._preguntas.isEmpty
              ? [Text("⚠️ No hay preguntas disponibles")]
              : _preguntas.map((p) => Text(p.contenido)).toList(),

            // 🔁 Generar dinámicamente preguntas sincronizadas
            ..._preguntas.map((p) {
              // Tratamiento especial para fecha de nacimiento y edad
              if (p.contenido.toLowerCase().contains("fecha de nacimiento")) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _fechaController,
                      decoration: _inputDecoration(p.contenido),
                      readOnly: true,
                      onTap: () => _seleccionarFechaNacimiento(context),
                      validator: (value) {
                        if (p.obligatoria && (value == null || value.isEmpty)) {
                          return 'Seleccione una fecha';
                        }
                        final date = _fechaNacimiento;
                        if (date != null && date.year == DateTime.now().year) {
                          return 'El año de nacimiento no puede ser el actual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // 🧮 Mostrar edad calculada automáticamente
                    if (_fechaNacimiento != null)
                      Text(
                        'Edad: ${DateTime.now().year - _fechaNacimiento!.year} años',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),

                    const SizedBox(height: 16),
                  ],
                );
              }


              // 🔡 Tipo: Texto / Número
              if (p.tipo.toLowerCase() == 'texto' || p.tipo.toLowerCase() == 'numero' || p.tipo.toLowerCase() == 'fecha') {
                return _buildTextField(p.contenido, p.id_pregunta!, obligatorio: p.obligatoria);
              }

              // ✔️ Tipo: Si_No
              if (p.tipo.toLowerCase() == 'si_no') {
                return _buildDropdown(p.contenido, p.id_pregunta!, ['Sí', 'No'], obligatorio: p.obligatoria);
              }

              // 📊 Tipo: Opción (puedes definir las opciones si las tienes)
      
              if (p.tipo.toLowerCase() == 'opcion') {
                final contenido = p.contenido.toLowerCase();
                List<String> opciones = ['Opción 1', 'Opción 2', 'Opción 3']; // default

                if (contenido.contains('RANGOS DE EDAD')) {
                  opciones = ['1-6', '7-11', '12-17', '18-25', '26-35', '36-49', '+50'];
                } else if (contenido.contains('GÉNERO')) {
                  opciones = ['Masculino', 'Femenino', 'Prefiero no decirlo', 'Otro'];
                } else if (contenido.contains('Estrato Socio-Economico?')) {
                  opciones = ['0-1', '2-3', '4+'];
                } else if (contenido.contains('URBANO O RURAL')) {
                  opciones = ['Urbano', 'Rural'];
                }

                return _buildDropdown(p.contenido, p.id_pregunta!, opciones, obligatorio: p.obligatoria);
              }


              return const SizedBox(); // fallback
            }),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStyledButton('Registrar asistente', const Color(0xFF00944C), _guardarAsistente),
                _buildStyledButton('Terminar registro', const Color(0xFF004A7F), _finalizarRegistro),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

}


