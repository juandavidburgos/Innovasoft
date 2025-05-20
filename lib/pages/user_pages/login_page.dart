import 'package:basic_flutter/pages/widgets/main_button.dart';
import 'package:basic_flutter/services/auth_service.dart';
import 'package:basic_flutter/services/local_service.dart';
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
    _localService.crearAdminTemporal();
  }

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final authService = AuthService(); // servicio que accede a SQLite

  Future <void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    

    try {
      // 1. Intentar login local
      final usuarioLocal = await authService.localLogin(email, password);
      if (usuarioLocal != null) {
        // Guardar sesión local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_usuario', usuarioLocal.id_usuario!);
        await prefs.setString('nombre_usuario', usuarioLocal.nombre);
        await prefs.setString('email_usuario', usuarioLocal.email);
        await prefs.setString('rol_usuario', usuarioLocal.rol);

        if (usuarioLocal.rol == 'ENTRENADOR') {
          Navigator.pushReplacementNamed(context, '/trainer_home');
        } else if (usuarioLocal.rol == 'ADMINISTRADOR') {
          Navigator.pushReplacementNamed(context, '/admin_home');
        }

        return; // ✅ No continúa a login remoto
      }

      // Solo intenta login remoto si está habilitado
      if (AppConfig.usarBackend) {
        final usuarioRemoto = await authService.remoteLogin(email, password);

        if (usuarioRemoto != null && usuarioRemoto.rol == 'ADMINISTRADOR') {
          Navigator.pushReplacementNamed(context, '/admin_home');
          return;
        }
      }


      /*if (usuarioLocal != null && usuarioLocal.rol == 'ENTRENADOR') {
        // Guardar sesión local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_usuario', usuarioLocal.idUsuario!);
        await prefs.setString('nombre_usuario', usuarioLocal.nombre);
        await prefs.setString('email_usuario', usuarioLocal.email);
        await prefs.setString('rol_usuario', usuarioLocal.rol);

        Navigator.pushReplacementNamed(context, '/trainer_home');
        return;
      }

      // 2. Si no es entrenador, intentar login remoto
      final usuarioRemoto = await authService.remoteLogin(email, password);

      if (usuarioRemoto != null && usuarioRemoto.rol == 'ADMINISTRADOR') {
        Navigator.pushReplacementNamed(context, '/admin_home');
        return;
      }

      // 3. Si ninguna autenticación fue válida
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales inválidas o rol no permitido'),
          backgroundColor: Colors.red,
        ),
      );*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de autenticación: Usuario o contraseña incorrectos!!!'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

