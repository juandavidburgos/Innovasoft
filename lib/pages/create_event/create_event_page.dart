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
        fecha_hora_inicio: _startDateTime!,
        fecha_hora_fin: _endDateTime!,
      );

      try {
        final success = await _repo.guardarEventoRemoto(nuevoEvento);

        if (success) {
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
        } else {
          print("No se guardo");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EventErrorPage()),
          );
        }
      } catch (e) {
        print(e);
        // Esto capturaría errores imprevistos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventErrorPage()),
        );
      }
    }
  }


  Future<DateTime?> _pickDateTime(BuildContext context, {required DateTime firstDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: firstDate.isAfter(DateTime.now()) ? firstDate : DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    final pickedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Validación adicional: si se selecciona una hora anterior a la hora de inicio
    if (_startDateTime != null &&
        date.year == _startDateTime!.year &&
        date.month == _startDateTime!.month &&
        date.day == _startDateTime!.day &&
        pickedDateTime.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora de finalización no puede ser anterior a la hora de inicio')),
      );
      return null;
    }

    return pickedDateTime;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
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
                    //final picked = await _pickDateTime(context);
                    final picked = await _pickDateTime(context, firstDate: DateTime.now());
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
                      validator: (_) {
                        if (_startDateTime == null) {
                          return 'Este campo es obligatorio';
                        }
                        final now = DateTime.now();
                        if (_startDateTime!.isBefore(now)) {
                          return 'La fecha de inicio no puede ser anterior a la fecha actual';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    //final picked = await _pickDateTime(context);
                    final picked = await _pickDateTime(
                      context,
                      firstDate: _startDateTime ?? DateTime.now(),
                    );
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
                        if (_startDateTime == null) {
                          return 'Primero selecciona la fecha de inicio';
                        }

                        if (_endDateTime!.isBefore(_startDateTime!)) {
                          return 'La fecha de finalización no puede ser anterior a la fecha de inicio';
                        }

                        // Validación adicional: si son el mismo día, compara horas
                        final sameDay = _startDateTime!.year == _endDateTime!.year &&
                            _startDateTime!.month == _endDateTime!.month &&
                            _startDateTime!.day == _endDateTime!.day;

                        if (sameDay && _endDateTime!.isBefore(_startDateTime!)) {
                          return 'La hora de finalización no puede ser anterior a la hora de inicio';
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
                      text: 'Regresar',
                      color: Color.fromARGB(255, 134, 134, 134),
                      icono: Icons.arrow_back,
                      ancho: 160,
                      alto: 50,
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