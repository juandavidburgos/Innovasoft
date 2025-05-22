import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../widgets/action_button.dart';

class AdminTrainerHomePage extends StatelessWidget {
  const AdminTrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.of(context).size.height;
    final anchoPantalla = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: alturaPantalla * 0.05),
                  Center(
                    child: Image.asset(
                      'assets/images/logo_indeportes.png',
                      width: anchoPantalla * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '“Indeportes somos todos”',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  MainButton(
                    texto: 'Asignar entrenador',
                    color: const Color(0xFF1A3E58),
                    icono: Icons.assignment,
                    ancho: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/assign_trainer');
                    },
                  ),
                  const SizedBox(height: 15),
                  MainButton(
                    texto: 'Editar asignación',
                    color: const Color(0xFF1A3E58),
                    icono: Icons.create,
                    ancho: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_assign');
                    },
                  ),
                  const SizedBox(height: 15),
                  MainButton(
                    texto: 'Visualizar asignaciones',
                    color: const Color(0xFF1A3E58),
                    icono: Icons.remove_red_eye,
                    ancho: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_assign');
                    },
                  ),
                  const SizedBox(height: 15),
                  MainButton(
                    texto: 'Listar entrenadores',
                    color: const Color(0xFF1A3E58),
                    icono: Icons.view_agenda,
                    ancho: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_users');
                    },
                  ),
                  const SizedBox(height: 15),
                  MainButton(
                    texto: 'Deshabilitar entrenadores',
                    color: const Color(0xFF1A3E58),
                    icono: Icons.disabled_visible,
                    ancho: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/disable_users');
                    },
                  ),
                  const SizedBox(height: 40),
                  ActionButton(
                    text: 'Regresar',
                    color: const Color.fromARGB(255, 134, 134, 134),
                    icono: Icons.arrow_back,
                    ancho: 145,
                    alto: 48,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/admin_home');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
