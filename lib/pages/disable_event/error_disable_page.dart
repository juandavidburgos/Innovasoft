import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

/// Página que se muestra cuando ocurre un error al deshabilitar eventos.
/// Regresa automáticamente a la pantalla anterior tras 2 segundos.
class ErrorDisablePage extends StatelessWidget {
  const ErrorDisablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de error
            Icon(Icons.error, size: 150, color: Colors.red),
            SizedBox(height: 20),
            // Mensaje de error
            const Text(
              "ERROR AL DESHABILITAR \n EL/LOS EVENTOS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
