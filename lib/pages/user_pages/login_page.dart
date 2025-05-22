import 'package:basic_flutter/models/user_model.dart';
import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/services/auth_service.dart';
import 'package:basic_flutter/services/local_service.dart';
import 'package:basic_flutter/services/remote_data_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:basic_flutter/app_config.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  
}

class _LoginPageState extends State<LoginPage> {
  final LocalService _localService = LocalService();
  bool _obscurePassword = true;


  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final authService = AuthService(); // servicio que accede a SQLite

  Future<void> _iniciarSesion() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  try {
    // 1. Intentar login local
    final usuarioLocal = await authService.localLogin(email, password);

    if (usuarioLocal != null) {
      await _guardarSesion(usuarioLocal);
      _redirigirSegunRol(usuarioLocal.rol);
      return;
    }

    // 2. Si está habilitado, intentar login remoto
    if (AppConfig.usarBackend)  {
      final usuarioRemoto = await authService.remoteLogin(email, password);
      if (usuarioRemoto != null && usuarioRemoto.rol == 'Administrador') {
        final token = RemoteDataService().ultimoToken;
        await _guardarSesion(usuarioRemoto, token: token);
        _redirigirSegunRol(usuarioRemoto.rol);
        return;
      }

      _mostrarError('Credenciales inválidas o usuario no autorizado.');
      return;
    }

    // 3. Si ninguna autenticación fue válida
    _mostrarError('Credenciales inválidas o rol no permitido');
  } catch (e) {
    _mostrarError('Error de autenticación: Usuario o contraseña incorrectos!!!');
  }
}

Future<void> _guardarSesion(UserModel usuario, {String? token}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('id_usuario', usuario.id_usuario!);
  await prefs.setString('nombre_usuario', usuario.nombre);
  await prefs.setString('email_usuario', usuario.email);
  await prefs.setString('rol_usuario', usuario.rol);

  if (usuario.rol == 'Monitor' && usuario.estado_monitor != null) {
    await prefs.setString('estado_monitor', usuario.estado_monitor!);
  }

  if (token != null) {
    await prefs.setString('jwt_token', token);
  }
}


void _redirigirSegunRol(String rol) {
  if (rol == 'Monitor') {
    Navigator.pushReplacementNamed(context, '/trainer_home');
  } else if (rol == 'Administrador') {
    Navigator.pushReplacementNamed(context, '/admin_home');
  }
}

void _mostrarError(String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 👈 importante
      body: SafeArea(
        child: SingleChildScrollView( // 👈 esto permite scroll cuando aparece el teclado
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // margen superior para evitar corte
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

                // Email
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
                        if (val == null || val.isEmpty) return 'Por favor ingresa tu correo';
                        if (!val.contains('@')) return 'Correo inválido';
                        return null;
                      },
                      onSaved: (val) => email = val!.trim().toLowerCase(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña con icono de visibilidad
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese la contraseña...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Por favor ingresa tu contraseña';
                        if (val.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                        return null;
                      },
                      onSaved: (val) => password = val!,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MainButton(
                      texto: 'Ingresar',
                      color: const Color(0xFF2E7D32),
                      onPressed: _iniciarSesion,
                    ),
                    const SizedBox(width: 10),
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

                // Olvidé contraseña
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // margen inferior para que no lo tape el teclado
              ],
            ),
          ),
        ),
      ),
    );
  }


}

