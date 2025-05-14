import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:basic_flutter/pages/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón logout (arriba a la derecha)
            Positioned(
              top: 0, // sobresale hacia arriba
              left: -20, // sobresale hacia la izquierda
              child: LogoutIconButton(
                ancho: 65,
                alto: 40,
                color: const Color.fromARGB(255, 143, 3, 3),
                icono: Icons.logout,
                alignment: MainAxisAlignment.end,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/logout_page');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Contenido principal centrado
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/home_events');
                      },
                    ),
                    const SizedBox(height: 15),
                    MainButton(
                      texto: 'Asignación de entrenadores',
                      color: const Color.fromARGB(255, 16, 88, 146),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/home_admin_trainer');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}