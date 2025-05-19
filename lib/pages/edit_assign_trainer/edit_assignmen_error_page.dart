import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

class EditAssignmentErrorPage extends StatelessWidget {
  const EditAssignmentErrorPage({super.key});

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
              'Fallo al editar la asignación de el/los \n entrenadores.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Mensaje de redirección
            const Text("Algunos entrenadores no se asignaron \n (ya podrían estar asignados)",
            style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            ActionButton(
                text: 'Regresar',
                color: Color.fromARGB(255, 134, 134, 134),
                icono: Icons.arrow_back,
                ancho: 145,
                alto: 48,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}