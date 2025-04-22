/*import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../pages/view_events_page.dart';

/// Página que permite al usuario crear un nuevo evento mediante un formulario.
/// Usa un `EventRepository` para guardar los datos localmente o remotamente.
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Clave para identificar el formulario y validar/guardar sus datos.
  final _formKey = GlobalKey<FormState>();

  // Instancia del repositorio para manejar la lógica de almacenamiento del evento.
  final EventRepository _repo = EventRepository();

  // Variables donde se guardarán temporalmente los valores del formulario.
  String _nombre = '';
  String _ubicacion = '';
  String _fecha = '';

  /// Método que se llama cuando el usuario presiona el botón "Guardar".
  /// Valida el formulario, guarda los datos y llama al repositorio para almacenar el evento.
  void _guardarEvento() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Se crea un nuevo objeto EventModel con los datos ingresados.
      final nuevoEvento = EventModel(
        nombre: _nombre,
        ubicacion: _ubicacion,
        fecha: _fecha,
      );

      // Se guarda el evento a través del repositorio.
      await _repo.agregarEvento(nuevoEvento);

      // Se muestra un mensaje al usuario indicando que se guardó exitosamente.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Evento guardado'),
      ));

      // Se reinicia el formulario para que esté vacío nuevamente.
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con el título.
      appBar: AppBar(title: const Text('Crear Evento')),

      // Contenido principal de la pantalla con padding alrededor.
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Formulario que contiene los campos para ingresar los datos del evento.
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para ingresar el nombre del evento.
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => _nombre = val!,
              ),

              // Campo para ingresar la ubicación del evento.
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ubicación'),
                onSaved: (val) => _ubicacion = val!,
              ),

              // Campo para ingresar la fecha del evento.
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fecha'),
                onSaved: (val) => _fecha = val!,
              ),

              const SizedBox(height: 20),

              // Botón para guardar el evento, llama a `_guardarEvento`.
              ElevatedButton(
                onPressed: _guardarEvento,
                child: const Text('Guardar'),
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
        ),
      ),
    );
  }
}*/

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
  String _location = '';
  DateTime? _selectedDate;
  late TextEditingController _dateController;

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

void _guardarEvento() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final nuevoEvento = EventModel(
      nombre: _name,
      ubicacion: _location,
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

      // Mostrar mensaje de éxito en la parte inferior de la pantalla
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Enter the name' : null,
                  onSaved: (val) => _name = val!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (val) {},
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Enter the location' : null,
                  onSaved: (val) => _location = val!,
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Date'),
                      validator: (_) => _selectedDate == null ? 'Enter the date' : null,
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

