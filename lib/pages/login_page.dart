import 'package:flutter/material.dart';
import 'create_event_page.dart'; // Importar la página a la que vamos a navegar

/// Página de inicio de sesión donde el usuario puede ingresar su correo y contraseña.
/// Simula un inicio de sesión y navega a la pantalla principal de la app.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Clave global para identificar el formulario y validar su contenido.
  final _formKey = GlobalKey<FormState>();

  // Variables que almacenan temporalmente los valores ingresados por el usuario.
  String _email = '';
  String _password = '';

  /// Método que se llama cuando el usuario presiona el botón "Iniciar sesión".
  /// Valida el formulario, muestra un mensaje y navega a la pantalla de eventos.
  void _iniciarSesion() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Simula autenticación exitosa.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inicio de sesión exitoso'),
      ));

      // Navega a la página principal de la app.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateEventPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título de la pantalla.
      appBar: AppBar(title: const Text('Iniciar Sesión')),

      // Contenido principal de la pantalla con padding.
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Formulario que contiene los campos de correo y contraseña.
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo para ingresar el correo electrónico.
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!val.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
                onSaved: (val) => _email = val!,
              ),

              // Campo para ingresar la contraseña.
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  if (val.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onSaved: (val) => _password = val!,
              ),

              const SizedBox(height: 20),

              // Botón que ejecuta el proceso de inicio de sesión.
              ElevatedButton(
                onPressed: _iniciarSesion,
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
