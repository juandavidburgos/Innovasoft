import 'package:flutter/material.dart';
import '../../services/local_service.dart';
import '../widgets/action_button.dart';
import '../user_pages/sucsess_reigster_page.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPage();
}

class _RegisterUserPage extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String email = '';
  String contrasena = '';
  String rol = 'ENTRENADOR';
  String _repeatPassword = '';
  String _tempPassword = '';
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  final _localService= LocalService();

  void _register() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      _formKey.currentState?.save();

      final nuevoUsuario = UserModel(
        nombre: nombre,
        email: email,
        contrasena: contrasena,
        rol: rol,
      );

      try {
        // Guardar en la base de datos y obtener el ID generado
        int usuarioId = await _localService.guardarUsuario(nuevoUsuario);

        // Guardar sesión en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_usuario', usuarioId);
        await prefs.setString('nombre_usuario', nuevoUsuario.nombre);
        await prefs.setString('email_usuario', nuevoUsuario.email);
        await prefs.setString('rol_usuario', nuevoUsuario.rol);

        // Redirigir a página de éxito
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessRegisterPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos correctamente'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
}


  bool _isPasswordValid(String value) {
    final hasNumber = RegExp(r'\d');
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return hasNumber.hasMatch(value) && hasSpecial.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
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
                  'Crear cuenta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Nombre completo
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ingrese su nombre...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                    onSaved: (val) => nombre = val!,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      hintText: 'Ingrese un correo electrónico...',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                    onSaved: (val) => email = val!,
                  ),
                ),

                const SizedBox(height: 16),

                // Contraseña
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingrese una contraseña...',
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
                      if (val == null || val.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (val.length < 6) {
                        return 'Debe tener al menos 6 caracteres';
                      }
                      if (!_isPasswordValid(val)) {
                        return 'Debe incluir al menos un número y un caracter\n especial';
                      }
                      _tempPassword = val; // Almacena temporalmente la contraseña para validación cruzada
                      return null;
                    },
                    onSaved: (val) => contrasena = val!,
                  ),
                ),


                const SizedBox(height: 16),

                // Repetir contraseña
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    obscureText: _obscureRepeatPassword,
                    decoration: InputDecoration(
                      labelText: 'Repetir contraseña',
                      hintText: 'Confirme su contraseña...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureRepeatPassword = !_obscureRepeatPassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Por favor repite la contraseña';
                      }
                      if (val != _tempPassword) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                    onSaved: (val) => _repeatPassword = val!,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botones
                    ActionButton(
                      text: 'Completar \n registro',
                      color: const Color(0xFF2E7D32),
                      onPressed: _register,
                    ),
                        const SizedBox(width: 10), 
                    ActionButton(
                      text: 'Regresar',
                      color: const Color.fromARGB(255, 134, 134, 134),
                      icono: Icons.arrow_back,
                      ancho: 145,
                      alto: 48,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



