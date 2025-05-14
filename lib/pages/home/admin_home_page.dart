import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
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
                  'assets/images/logo_indeportes.png',
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Gestión de eventos',
                  color: const Color.fromARGB(255, 232, 78, 17),
                  onPressed: () {
                    //Redigir a la pagina
                    Navigator.pushNamed(context, '/home_events');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Asignación de entrenadores',
                  color: const Color.fromARGB(255, 16, 88, 146),
                  onPressed: () {
                    //Redigir a la pagina
                    Navigator.pushNamed(context, '/home_admin_trainer');
                  },
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/trainer_select_event');
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