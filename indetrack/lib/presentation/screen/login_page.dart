import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/indeportes_logo.png', height: 180),
              const SizedBox(height: 10),
              const Text(
                '“Indeportes somos todos”',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'Ingrese su correo...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese la contraseña...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navegar a home_page.dart
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('INGRESAR', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Acción para recuperar contraseña
                },
                child: const Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
