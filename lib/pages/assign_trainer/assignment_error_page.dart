import 'package:flutter/material.dart';
import '../assign_trainer/trainer_assignment_page.dart';

class AssignmentErrorPage extends StatelessWidget {
  const AssignmentErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperar 2 segundos antes de redirigir
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TrainerAssignmentPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 150),
            const SizedBox(height: 20),
            const Text(
              'Fallo al realizar la asignación!',
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
