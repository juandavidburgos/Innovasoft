import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

class EventErrorPage extends StatelessWidget {
  const EventErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 150),
            const SizedBox(height: 10),
            const Text(
              'Fallo al crear el evento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Mensaje de redirección
            const Text("Comuníquese con el administrador de \n la aplicación para resolver el problema.",
            style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            ActionButton(
                text: 'Regresar',
                color: Color.fromARGB(255, 134, 134, 134),
                icono: Icons.arrow_back,
                ancho: 160,
                alto: 50,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}
