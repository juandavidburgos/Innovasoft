import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:flutter/material.dart';

/// Página para confirmar si realmente se desea cerrar sesión.
class ConfirmLogoutPage extends StatelessWidget {
  const ConfirmLogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: const Color.fromARGB(255, 143, 3, 3), size: 150),
            const SizedBox(height: 10),
            const Text(
              "¿Está seguro que desea cerrar sesión?",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Cancelar
                ActionButton(
                  text: "Cancelar",
                  color: Color(0xFF1A3E58),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, "/admin_home");
                  }
                ),
                // Botón Confirmar
                ActionButton(
                  text: "Confirmar",
                  color: Color.fromARGB(255, 134, 134, 134),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/trainer_home');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
