import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../pages/create_event_page.dart'; // Asegúrate de importar la página correcta

class EventSuccessPage extends StatelessWidget {
  const EventSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperar 2 segundos antes de redirigir
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateEventPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'EVENT CREATED!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
