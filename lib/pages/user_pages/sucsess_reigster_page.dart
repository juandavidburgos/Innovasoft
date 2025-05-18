import 'package:basic_flutter/pages/user_pages/login_page.dart';
import 'package:flutter/material.dart';

/// Página que muestra un mensaje de éxito tras deshabilitar eventos.
/// Redirige automáticamente a la pantalla principal después de 2 segundos.
class SuccessRegisterPage extends StatefulWidget {
  const SuccessRegisterPage({super.key});

  @override
  State<SuccessRegisterPage> createState() => _SuccessRegisterPage();
}

class _SuccessRegisterPage extends State<SuccessRegisterPage> {
  @override
  void initState() {
    super.initState();

    // Espera 2 segundos antes de volver al inicio
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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
              "Registro exitoso!",
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
