import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../../../models/event_model.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/indeportes_logo.png',
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
                MainButton(
                  texto: 'Crear evento',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed(context,'/crear_evento');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Editar evento',
                  color: Colors.orange,
                  onPressed: () {
                    //Ejemplo de prueba
                    /*final eventToEdit = EventModel(
                      id: 1,
                      name: 'Evento de prueba',
                      description: 'Descripción',
                      location: 'Lugar',
                      date: DateTime.now(),
                    );
                    
                    Navigator.pushNamed(
                      context, 
                      '/edit_event',
                      arguments: eventToEdit,
                      );*/
                    //Redigir a la pagina
                    Navigator.pushNamed(context, '/edit_event');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Deshabilitar evento',
                  color: Colors.red,
                  onPressed: () {Navigator.pushNamed(context, '/disable_event');},
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Asignar entrenador',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/assign_trainer');
                  },
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Salir', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}