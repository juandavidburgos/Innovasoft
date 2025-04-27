import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../../../models/event_model.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

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
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft, // Alineado a la izquierda
                  child: Text(
                    'Registro de asistencia de eventos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MainButton(
                  texto: 'Evento nuevo',
                  color: Colors.blue,
                  onPressed: () {Navigator.pushNamed(context, '/disable_event');},
                ),
                const SizedBox(height: 20),
                MainButton(
                  texto: 'Evento fijo',
                  color: Colors.orange,
                  onPressed: () {Navigator.pushNamed(context, '/disable_event');},
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
                  child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}