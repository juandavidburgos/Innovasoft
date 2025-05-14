import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'final_register_page.dart';
import 'package:basic_flutter/models/event_model.dart'; // importa tu modelo

class AssistenceRegisterPage extends StatefulWidget {
  final EventModel evento; // ← EVENTO REQUERIDO

  const AssistenceRegisterPage({
    super.key,
    required this.evento,
  });

  @override
  State<AssistenceRegisterPage> createState() => _AssistenceRegisterPageState();
}

class _AssistenceRegisterPageState extends State<AssistenceRegisterPage> {
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
  }

  void _finalizarRegistro() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _asistentes.add(Map<String, dynamic>.from(_formData));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalRegisterPage(
            asistentes: _asistentes,
            evento: widget.evento, // ← PASA EL EVENTO AQUÍ
          ),
        ),
      );
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Indeportes Cauca'),
        centerTitle: true,
        backgroundColor: const Color(0xFF004A7F),
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
                  'Registro de Asistente',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 25),
              _buildTextField('Nombres', 'nombres', obligatorio: true),
              _buildTextField('Apellidos', 'apellidos', obligatorio: true),
              _buildTextField('Número de identificación', 'identificacion', obligatorio: true, tipo: TextInputType.number),
              _buildTextField('Ocupación', 'ocupacion', obligatorio: true),
              const SizedBox(height: 3),
              TextFormField(
                controller: _fechaController,
                decoration: _inputDecoration('Fecha de nacimiento'),
                readOnly: true,
                onTap: () => _seleccionarFechaNacimiento(context),
                validator: (value) => value == null || value.isEmpty ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 3),
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
              _buildTextField('Teléfono / Correo', 'contacto', obligatorio: true),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStyledButton('Registrar otro asistente', const Color(0xFF00944C), _guardarAsistente),
                  _buildStyledButton('Terminar registro', const Color(0xFF004A7F), _finalizarRegistro),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

}
