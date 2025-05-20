import 'package:basic_flutter/repositories/forms_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'final_register_page.dart';
import 'package:basic_flutter/models/event_model.dart'; // importa tu modelo

class AssistenceRegisterPage extends StatefulWidget {
  final EventModel evento;

  const AssistenceRegisterPage({super.key, required this.evento});

  @override
  State<AssistenceRegisterPage> createState() => _AssistenceRegisterPageState();
}

class _AssistenceRegisterPageState extends State<AssistenceRegisterPage> {
  final FormsRepository _repo = FormsRepository();

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final List<Map<String, dynamic>> _asistentes = [];
  DateTime? _fechaNacimiento;
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  void _actualizarEdad(DateTime fecha) {
    final edad = DateTime.now().year - fecha.year;
    _edadController.text = edad.toString();
    setState(() {
      _formData['edad'] = edad;
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

  Widget _buildTextField(String label, String key,
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

        switch (key) {
          case 'identificacion':
            if (value != null && (value.length < 8 || value.length > 10)) {
              return 'Debe tener entre 8 y 10 dígitos';
            }
            break;
          case 'contacto':
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return 'Ingrese solo números';
            }
            if (value.length < 10) {
              return 'Ingrese un teléfono válido (mínimo 10 dígitos)';
            }
            break;
          case 'correo_electronico':
            if (value != null && value.isNotEmpty) {
              if (value.contains(' ')) {
                return 'El correo no debe contener espacios';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Correo inválido';
              }
            }
            break;
          case 'meses_embarazo':
            if (value != null &&
                value.isNotEmpty &&
                !RegExp(r'^\d+$').hasMatch(value)) {
              return 'Ingrese solo números';
            }
            break;
          case 'experiencia':
            if (value != null && !RegExp(r'^\d+$').hasMatch(value)) {
              return 'Ingrese solo números';
            }
            break;
          case 'edad':
            if (value != null && !RegExp(r'^\d+$').hasMatch(value)) {
              return 'Edad inválida';
            }
            break;
        }

        return null;
      },
      onSaved: (value) => _formData[key] = value,
    );
  }

  Widget _buildDropdown(String label, String key, List<String> opciones,
      {bool obligatorio = false}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) => _formData[key] = value,
      validator: (value) {
        if (obligatorio && (value == null || value.isEmpty)) {
          return 'Seleccione una opción';
        }
        return null;
      },
    );
  }

  void _guardarAsistente() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _asistentes.add(Map<String, dynamic>.from(_formData));
      _formKey.currentState!.reset();
      _fechaController.clear();
      _edadController.clear();
      _formData.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Asistente registrado.')));
    }
    _mostrarResumenAsistente(_asistentes.last);

  }

void _finalizarRegistro() {
  final isFormValid = _formKey.currentState!.validate();

  if (_asistentes.isEmpty) {
    // No hay asistentes aún: el formulario debe estar completamente válido
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: 
          Text('Debe registrar al menos un asistente con todos los campos obligatorios.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
        
      );
      return;
    } else {
      _formKey.currentState!.save();
      _asistentes.add(Map<String, dynamic>.from(_formData));
    }
  } else {
    // Ya hay al menos un asistente: guardar actual si es válido
    if (isFormValid) {
      _formKey.currentState!.save();
      _asistentes.add(Map<String, dynamic>.from(_formData));
    }
    // Si no es válido, simplemente ignora el actual y continúa
  }

  // Ir a la página final
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FinalRegisterPage(
        asistentes: _asistentes,
        evento: widget.evento,
      ),
    ),
  );
}

void _mostrarResumenAsistente(Map<String, dynamic> asistente) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Asistente registrado'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: asistente.entries.map((entry) {
            return Text('${entry.key}: ${entry.value}');
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

/* *VERIFICAR!!

Future<bool> hayInternet() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}

List<AnswerModel> _crearRespuestasDesdeFormulario(int formId) {
  int preguntaId = 1;
  return _formData.entries.map((entry) {
    return AnswerModel(
      preguntaId: preguntaId++, // puedes definir este orden como quieras
      formularioId: formId,
      contenido: entry.value?.toString() ?? '',
    );
  }).toList();
}

void _guardarAsistente() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  final formId = DateTime.now().millisecondsSinceEpoch;

  final form = FormModel(
    idFormulario: formId,
    eventoId: widget.evento.idEvento,
    idUsuario: usuarioId,
    titulo: 'Asistente',
    descripcion: 'Registro individual',
    fechaCreacion: DateTime.now().toIso8601String(),
    latitud: null,
    longitud: null,
    pathImagen: null,
  );

  final respuestas = _crearRespuestasDesdeFormulario(formId);

  final conectado = await hayInternet();

  if (conectado) {
    final enviado = await _repo.enviarFormularioConRespuestas(form, respuestas);
    if (!enviado) await _repo.guardarEnColaPeticiones(form, respuestas);
  } else {
    await _repo.guardarEnColaPeticiones(form, respuestas);
  }

  _formKey.currentState!.reset();
  _formData.clear();
  _fechaController.clear();
  _edadController.clear();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Asistente registrado.')),
  );
}

 */

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
          style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A3E58),
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
              _buildTextField('Nombres', 'nombres', obligatorio: true),
              _buildTextField('Apellidos', 'apellidos', obligatorio: true),
              _buildTextField('Número de identificación', 'identificacion', obligatorio: true, tipo: TextInputType.number),
              _buildTextField('Ocupación', 'ocupacion', obligatorio: true),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fechaController,
                decoration: _inputDecoration('Fecha de nacimiento'),
                readOnly: true,
                onTap: () => _seleccionarFechaNacimiento(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
              _buildTextField('Edad', 'edad', controller: _edadController, obligatorio: true, tipo: TextInputType.number),
              const SizedBox(height: 10),
              _buildDropdown('Rango de edad', 'rango_edad', ['1-6', '7-11', '12-17', '18-25', '26-35', '36-49', '+50'], obligatorio: true),
              _buildDropdown('Género', 'genero', ['Masculino', 'Femenino', 'Prefiero no decirlo', 'Otro'], obligatorio: true),
              _buildDropdown('¿Está en embarazo?', 'embarazo', ['Sí', 'No'], obligatorio: true),
              _buildTextField('Meses de embarazo (si aplica)', 'meses_embarazo'),
              _buildDropdown('¿Víctima del conflicto armado?', 'victima_conflicto', ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Inscrito en VIVANTO?', 'vivanto', ['Sí', 'No']),
              _buildDropdown('Estrato socioeconómico', 'estrato', ['0-1', '2-3', '4+'], obligatorio: true),
              _buildDropdown('¿Grupo social o étnico?', 'grupo_social', ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Posee alguna discapacidad?', 'discapacidad', ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Practica una disciplina deportiva?', 'deporte', ['Sí', 'No'], obligatorio: true),
              _buildTextField('¿Cuál disciplina?', 'disciplina'),
              _buildTextField('Categoría deportiva', 'categoria'),
              _buildTextField('Institución educativa', 'institucion'),
              _buildTextField('Club al que pertenece', 'club'),
              _buildTextField('Liga a la que pertenece', 'liga'),
              _buildDropdown('¿Ha tenido lesiones?', 'lesiones', ['Sí', 'No'], obligatorio: true),
              _buildTextField('Años de experiencia deportiva', 'experiencia', obligatorio: true, tipo: TextInputType.number),
              _buildTextField('Dirección', 'direccion', obligatorio: true),
              _buildTextField('Municipio de origen', 'municipio', obligatorio: true),
              _buildDropdown('Zona', 'zona', ['Urbano', 'Rural'], obligatorio: true),
              _buildTextField('Teléfono', 'contacto', obligatorio: true),
              _buildTextField('Correo electrónico', 'correo_electronico'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStyledButton('Registrar otro asistente', const Color(0xFF00944C), _guardarAsistente),
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

