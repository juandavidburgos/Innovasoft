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
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    overlayColor: Colors.blueGrey,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
                ),
                // Botón Confirmar
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 107, 107, 107),
                    overlayColor: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
