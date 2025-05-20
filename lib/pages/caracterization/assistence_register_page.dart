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
  final Map<int, dynamic> _formData = {};
  final List<Map<String, dynamic>> _asistentes = [];
  DateTime? _fechaNacimiento;
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

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

  Widget _buildTextField(String label, int pregunta_id,
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
        switch (pregunta_id) {
          case 3: // DOCUMENTO IDENTIDAD
            if (value != null && (value.length < 8 || value.length > 10)) {
              return 'Debe tener entre 8 y 10 dígitos';
            }
            break;
          case 25: // TELÉFONO
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
          case 26: // CORREO ELECTRÓNICO
            if (value != null && value.isNotEmpty) {
              if (value.contains(' ')) {
                return 'El correo no debe contener espacios';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Correo inválido';
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
      onSaved: (value) => _formData[pregunta_id] = value,
    );
  }


  Widget _buildDropdown(String label, int pregunta_id, List<String> opciones,
      {bool obligatorio = false}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) => _formData[pregunta_id] = value,
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
    // Ir a la vista final
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalRegisterPage(
          evento: widget.evento,
          usuarioId: usuarioId,
          id_formulario: id_formulario,
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


List<AnswerModel> _crearRespuestasDesdeFormulario(int id_formulario) {
  return _formData.entries.map((entry) {
    return AnswerModel(
      pregunta_id: entry.key,              // 
      id_formulario: id_formulario,
      contenido: entry.value?.toString() ?? '',
      id_evento: widget.evento.idEvento,   // 
    );
  }).toList();
}


void _guardarAsistente() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  final id_formulario = DateTime.now().millisecondsSinceEpoch;

  final form = FormModel(
    id_formulario: id_formulario,
    id_evento: widget.evento.id_evento,
    id_usuario: id_usuario,
    titulo: 'Asistente',
    descripcion: 'Registro individual',
    fechaCreacion: DateTime.now().toIso8601String(),
    latitud: null,
    longitud: null,
    path_imagen: null,
  );

  final respuestas = _crearRespuestasDesdeFormulario(id_formulario);

  final conectado = await _repo.hayConexion();

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
              _buildTextField('Nombres', 1, obligatorio: true),
              _buildTextField('Apellidos', 2, obligatorio: true),
              _buildTextField('Número de identificación', 3, obligatorio: true, tipo: TextInputType.number),
              _buildTextField('Ocupación', 4, obligatorio: true),
              const SizedBox(height: 20),

              // FECHA DE NACIMIENTO (id = 5) y EDAD (id = 6)
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
              _buildTextField('Edad', 6, controller: _edadController, obligatorio: true, tipo: TextInputType.number),

              const SizedBox(height: 10),
              _buildDropdown('Rango de edad', 7, ['1-6', '7-11', '12-17', '18-25', '26-35', '36-49', '+50'], obligatorio: true),
              _buildDropdown('Género', 8, ['Masculino', 'Femenino', 'Prefiero no decirlo', 'Otro'], obligatorio: true),
              _buildDropdown('¿Está en embarazo?', 9, ['Sí', 'No'], obligatorio: true),
              _buildTextField('Meses de embarazo (si aplica)', 9), // mismo campo, solo se separa visualmente
              _buildDropdown('¿Víctima del conflicto armado?', 10, ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Inscrito en VIVANTO?', 10, ['Sí', 'No']), // mismo ID como pregunta compuesta
              _buildDropdown('Estrato socioeconómico', 11, ['0-1', '2-3', '4+'], obligatorio: true),
              _buildDropdown('¿Grupo social o étnico?', 12, ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Posee alguna discapacidad?', 13, ['Sí', 'No'], obligatorio: true),
              _buildDropdown('¿Practica una disciplina deportiva?', 14, ['Sí', 'No'], obligatorio: true),
              _buildTextField('¿Cuál disciplina?', 14),
              _buildTextField('Categoría deportiva', 15),
              _buildTextField('Institución educativa', 16),
              _buildTextField('Club al que pertenece', 17),
              _buildTextField('Liga a la que pertenece', 18),
              _buildDropdown('¿Ha tenido lesiones?', 19, ['Sí', 'No'], obligatorio: true),
              _buildTextField('Años de experiencia deportiva', 21, obligatorio: true, tipo: TextInputType.number),
              _buildTextField('Dirección', 22, obligatorio: true),
              _buildTextField('Municipio de origen', 23, obligatorio: true),
              _buildDropdown('Zona', 24, ['Urbano', 'Rural'], obligatorio: true),
              _buildTextField('Teléfono', 25, obligatorio: true),
              _buildTextField('Correo electrónico', 26),
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

