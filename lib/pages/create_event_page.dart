import 'package:flutter/material.dart';
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
}
