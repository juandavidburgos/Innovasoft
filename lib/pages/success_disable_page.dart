import 'package:flutter/material.dart';

/// Página que muestra un mensaje de éxito tras deshabilitar eventos.
/// Redirige automáticamente a la pantalla principal después de 2 segundos.
class SuccessDisablePage extends StatefulWidget {
  const SuccessDisablePage({super.key});

  @override
  State<SuccessDisablePage> createState() => _SuccessDisablePageState();
}

class _SuccessDisablePageState extends State<SuccessDisablePage> {
  @override
  void initState() {
    super.initState();

    // Espera 2 segundos antes de volver al inicio
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de éxito
            Icon(Icons.check_circle, size: 150, color: Colors.green),

            SizedBox(height: 20),

            // Mensaje de confirmación
            Text(
              "EVENTO(S) DESHBAILITADO(S) \n EXISOTSAMENTE!",
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
