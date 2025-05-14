import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';
import 'event_error_page.dart';
import 'event_success_page.dart';
import '../widgets/action_button.dart';

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

  final DateFormat _dateTimeFormat = DateFormat('dd-MM-yyyy HH:mm');

  String _name = '';
  String _descripcion = '';
  String? _location;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<String> _municipios = [];

  late TextEditingController _startDateTimeController;
  late TextEditingController _endDateTimeController;

  @override
  void initState() {
    super.initState();
    _startDateTimeController = TextEditingController();
    _endDateTimeController = TextEditingController();
    cargarMunicipios().then((municipios) {
      setState(() {
        _municipios = municipios;
      });
    });
  }

  @override
  void dispose() {
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    super.dispose();
  }

  void _guardarEvento() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final nuevoEvento = EventModel(
        nombre: _name,
        ubicacion: _location!,
        descripcion: _descripcion,
        // Aquí se envían las fechas de inicio y fin
        fechaHoraInicio: _startDateTime!,
        fechaHoraFin: _endDateTime!,
      );

      try {
        await _repo.agregarEvento(nuevoEvento);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventSuccessPage()),
        );

        _formKey.currentState!.reset();
        _startDateTimeController.clear();
        _endDateTimeController.clear();
        setState(() {
          _startDateTime = null;
          _endDateTime = null;
        });
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventErrorPage()),
        );
      }
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                      Image.asset('assets/images/logo_indeportes.png', height: 100),
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
                  onSaved: (val) => _descripcion = val ?? '',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Ubicación'),
                  value: _location,
                  hint: const Text('Selecciona un municipio'),
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
                  onTap: () async {
                    final picked = await _pickDateTime(context);
                    if (picked != null) {
                      setState(() {
                        _startDateTime = picked;
                        _startDateTimeController.text = _dateTimeFormat.format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startDateTimeController,
                      decoration: _inputDecoration('Fecha y hora de inicio'),
                      validator: (_) =>
                          _startDateTime == null ? 'Este campo es obligatorio' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await _pickDateTime(context);
                    if (picked != null) {
                      setState(() {
                        _endDateTime = picked;
                        _endDateTimeController.text = _dateTimeFormat.format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _endDateTimeController,
                      decoration: _inputDecoration('Fecha y hora de finalización'),
                      validator: (_) {
                        if (_endDateTime == null) {
                          return 'Este campo es obligatorio';
                        }
                        if (_endDateTime!.isBefore(_startDateTime!)) {
                          return 'La fecha de finalización no puede ser anterior a la fecha de inicio';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'GUARDAR',
                      color: Color(0xFF038C65),
                      onPressed: _guardarEvento,
                    ),
                    ActionButton(
                      text: 'VOLVER',
                      color: Color(0xFF1D5273),
                      onPressed: () => Navigator.pop(context),
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