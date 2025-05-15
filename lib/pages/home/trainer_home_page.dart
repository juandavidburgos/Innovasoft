import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../widgets/logout_button.dart';

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});
  @override
  State<TrainerHomePage> createState() => _TrainerHomePage();
  
}

class _TrainerHomePage extends State<TrainerHomePage> {
  String nombreUsuario = 'Carlos Ramírez';
  int usuarioId = 1; // Simulado
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón logout (arriba a la derecha)
            Positioned(
              top: 10, // sobresale hacia arriba
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
                    const SizedBox(height: 20),
                    // Línea divisora
                    const Divider(
                      thickness: 1.5,
                      color: Color(0xFFCCCCCC),
                      height: 30,
                    ),

                    // Bienvenida alineada a la izquierda
                    Text(
                      'Bienvenido, $nombreUsuario',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Divider(
                      thickness: 1.5,
                      color: Color(0xFFCCCCCC),
                      height: 30,
                    ),
                    const SizedBox(height: 20),
                    MainButton(
                      texto: 'Evento nuevo',
                      color: const Color.fromARGB(255, 232, 78, 17),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/trainer_select_event');
                      },
                    ),
                    const SizedBox(height: 15),
                    MainButton(
                      texto: 'Evento fijo',
                      color: const Color.fromARGB(255, 16, 88, 146),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/trainer_select_event');
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
