import 'package:flutter/material.dart';
import '../widgets/main_button.dart';

class AdminEventHomePage extends StatelessWidget {
  const AdminEventHomePage({super.key});

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
                const SizedBox(height: 30),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
                MainButton(
                  texto: 'Crear evento',
                  color: Color(0xFF038C65),
                  onPressed: () {
                    Navigator.pushNamed(context,'/crear_evento');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Editar evento',
                  color: Color(0xFFF25430),
                  onPressed: () {
                    //Redigir a la pagina
                    Navigator.pushNamed(context, '/edit_event');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Ver eventos',
                  color: Color(0xFF1D5273),
                  onPressed: () {
                    Navigator.pushNamed(context,'/view_event');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Deshabilitar evento',
                  color: Color(0xFFE53935),
                  onPressed: () {Navigator.pushNamed(context, '/disable_event');},
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/admin_home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB71C1C),
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