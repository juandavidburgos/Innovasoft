import 'package:flutter/material.dart';

/// Página que se muestra cuando ocurre un error al deshabilitar eventos.
/// Regresa automáticamente a la pantalla anterior tras 2 segundos.
class ErrorDisablePage extends StatefulWidget {
  const ErrorDisablePage({super.key});

  @override
  State<ErrorDisablePage> createState() => _ErrorDisablePageState();
}

class _ErrorDisablePageState extends State<ErrorDisablePage> {
  @override
  void initState() {
    super.initState();

    // Espera 2 segundos antes de regresar a la pantalla anterior
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de error
            Icon(Icons.error, size: 80, color: Colors.red),

            SizedBox(height: 20),

            // Mensaje de error
            Text(
              "Error al deshabilitar los eventos.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),

            // Mensaje de redirección
            Text("Regresando...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
