import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import 'event_error_page.dart';
import 'event_success_page.dart';
import '../pages/view_events_page.dart';
import 'widgets/action_button.dart'; // Asegúrate de importar ActionButton

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventRepository _repo = EventRepository();

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  String _name = '';
  String? _location;  // Ubicación seleccionada
  DateTime? _selectedDate;
  List<String> _municipios = [];
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
     cargarMunicipios().then((municipios) {
    setState(() {
      _municipios = municipios;
    });
  });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _guardarEvento() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final nuevoEvento = EventModel(
        nombre: _name,
        ubicacion: _location!,
        fecha: _selectedDate!,
      );

      try {
        await _repo.agregarEvento(nuevoEvento);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventSuccessPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento guardado con éxito')),
        );

        _formKey.currentState!.reset();
        _dateController.clear();
        setState(() {
          _selectedDate = null;
        });
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventErrorPage()),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _dateFormat.format(pickedDate);
      });
    }
  }

Future<List<String>> cargarMunicipios() async {
  final data = await rootBundle.loadString('assets/utils/municipios_cauca.json');
  final List<dynamic> jsonResult = json.decode(data);
  return List<String>.from(jsonResult);
}

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: 'Ingrese $label',
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/indeportes_logo.png', height: 80),
                      const Text('"Indeportes somos todos"',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 20),
                      const Text('Crear Evento',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration('Nombre'),
                  validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _inputDecoration('Descripción'),
                  onSaved: (val) {},
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Ubicación'),
                  value: _location,
                  hint: Text('Selecciona un municipio'),
                  items: _municipios.map((String municipio) {
                    return DropdownMenuItem<String>(
                      value: municipio,
                      child: Text(municipio),
                    );
                  }).toList(),
                  onChanged: (nuevo) {
                    setState(() {
                      _location = nuevo;
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
                  onSaved: (val) => _location = val!,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: _inputDecoration('Fecha'),
                      validator: (_) =>
                          _selectedDate == null ? 'Este campo es obligatorio' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          text: 'GUARDAR',
                          color: Colors.green,
                          onPressed: _guardarEvento,
                        ),
                        ActionButton(
                          text: 'VER EVENTOS',
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ViewEventsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ActionButton(
                        text: 'VOLVER',
                        color: Colors.blue,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}