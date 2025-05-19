import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../widgets/action_button.dart';
class AdminTrainerHomePage extends StatelessWidget {
  const AdminTrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: alturaPantalla * 0.85, // Centra más abajo
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Empieza desde arriba
              children: [
                const SizedBox(height: 120), // <-- EMPUJA TODO HACIA ABAJO
                Image.asset(
                  'assets/images/logo_indeportes.png',
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 30),
                MainButton(
                  texto: 'Asignar entrenador',
                  color: Color(0xFF1A3E58),
                  icono: Icons.assignment,
                  ancho: 270,
                  onPressed: () {
                    Navigator.pushNamed(context, '/assign_trainer');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Editar asignación',
                  color: Color(0xFF1A3E58),
                  icono: Icons.create,
                  ancho: 270,
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_assign');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Visualizar asignaciones',
                  color: Color(0xFF1A3E58),
                  icono: Icons.remove_red_eye,
                  ancho: 270,
                  onPressed: () {
                    Navigator.pushNamed(context, '/view_assign');
                  },
                ),
                const SizedBox(height: 15),
                  MainButton(
                    texto: 'Listar entrenadores',
                    color: Color(0xFF1A3E58),
                    icono: Icons.view_agenda,
                    ancho: 270,
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_users');
                    },
                  ),
                  const SizedBox(height: 15),
                  MainButton(
                    texto: 'Deshabilitar entrenadores',
                    color: Color(0xFF1A3E58),
                    icono: Icons.disabled_visible,
                    ancho: 270,
                    onPressed: () {
                      Navigator.pushNamed(context, '/disable_users');
                    },
                  ),
                const SizedBox(height: 50),
                ActionButton(
                  text: 'Regresar',
                  color: Color.fromARGB(255, 134, 134, 134),
                  icono: Icons.arrow_back,
                  ancho: 145,
                  alto: 48,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/admin_home');
                  },
                ),
              ],
            ),

            ),
          ),
        ),
      ),
    );
  }

}