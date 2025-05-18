import 'dart:convert';
import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  
void _iniciarSesion() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final url = Uri.parse('https://tu-backend.com/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _email,
        'password': _password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token'];

      // Decodificar el token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String rol = decodedToken['rol'];
      String nombre = decodedToken['nombre'];
      int idUsuario = decodedToken['id_usuario'];

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('nombreUsuario', nombre);
      await prefs.setInt('idUsuario', idUsuario);
      await prefs.setString('rol', rol);

      // Navegar según el rol
      if (rol == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_home');
      } else if (rol == 'trainer') {
        Navigator.pushReplacementNamed(context, '/trainer_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol no reconocido')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales inválidas: ${response.body}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_indeportes.png',
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Campo de correo electrónico
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'Ingrese su correo...',
                        border: OutlineInputBorder(),
                      ),
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
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese la contraseña...',
                        border: OutlineInputBorder(),
                      ),
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
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MainButton(
                        texto: 'Ingresar',
                        color: const Color(0xFF2E7D32),
                        onPressed: _iniciarSesion,
                      ),
                    const SizedBox(width: 10), // espacio entre botones
                    MainButton(
                        texto: 'Registrarme',
                        color: const Color(0xFF105892),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/user_register');
                        },
                      ),
                  ],
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
      ),
    );
  }

}

