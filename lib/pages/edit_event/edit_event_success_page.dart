import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'edit_event_page.dart'; // Asegúrate de importar la página correcta

class EditEventSuccessPage extends StatelessWidget {
  const EditEventSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperar 2 segundos antes de redirigir
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EditEventPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 150),
            const SizedBox(height: 20),
            const Text(
              'EVENTO EDITADO \n EXITOSAMENTE!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Mensaje de redirección
            const Text("Regresando...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
