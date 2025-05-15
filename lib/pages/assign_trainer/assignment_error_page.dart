import 'package:flutter/material.dart';

class AssignmentErrorPage extends StatelessWidget {
  const AssignmentErrorPage({super.key});

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
              'FALLO AL ASIGNAR EL/LOS \n ENTRENADOR(ES)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Mensaje de redirección
            const Text("Algunos entrenadores no se asignaron \n (ya podrían estar asignados)",
            style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Navigator.pop(context),
              child: const Text('VOLVER', style: TextStyle(color: Colors.white))
            ),
          ],
        ),
      ),
    );
  }
}
