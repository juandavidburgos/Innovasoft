import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import 'event_error_page.dart';
import 'event_success_page.dart';
import '../pages/view_events_page.dart';

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
  String? _selectedLocation;  // Ubicación seleccionada
  DateTime? _selectedDate;
  late TextEditingController _dateController;

  // Lista de ubicaciones
  List<String> _locations = [
    'Ubicación 1',
    'Ubicación 2',
    'Ubicación 3',
    'Ubicación 4',
  ];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Función para guardar el evento
  void _guardarEvento() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final nuevoEvento = EventModel(
        nombre: _name,
        ubicacion: _selectedLocation!,  // Usamos la ubicación seleccionada
        fecha: _selectedDate!,
      );

      try {
        // Intentar guardar el evento en la base de datos
        await _repo.agregarEvento(nuevoEvento);

        // Redirigir a la página de éxito si el guardado es exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventSuccessPage()),
        );

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Evento guardado con éxito'),
        ));

        // Limpiar el formulario
        _formKey.currentState!.reset();
        _dateController.clear();
        setState(() {
          _selectedDate = null;
        });
      } catch (e) {
        // Si ocurre un error, redirigir a la página de error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventErrorPage()),
        );
      }
    }
  }

  // Función para seleccionar la fecha
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/indeportes_logo.png', height: 80),
                      const Text(
                        '"Indeportes somos todos"',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Event',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre del evento'),
                  validator: (value) => value!.isEmpty ? 'Ingrese el nombre del evento...' : null,
                  onSaved: (val) => _name = val!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción del evento'),
                  onSaved: (val) {},
                ),
                // Aquí reemplazamos el campo de ubicación por un DropdownButton
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  hint: const Text('Selecciona la ubicación del evento'),
                  validator: (value) => value == null ? 'Seleccione una ubicación' : null,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLocation = newValue;
                    });
                  },
                  items: _locations.map<DropdownMenuItem<String>>((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Fecha de desarrollo'),
                      validator: (_) => _selectedDate == null ? 'Ingrese la fecha de desarrollo del evento...' : null,
                      controller: _dateController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                      onPressed: _guardarEvento,
                      child: const Text('Guardar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('BACK'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ViewEventsPage()),
                        );
                      },
                      child: const Text('Ver eventos creados'),
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
