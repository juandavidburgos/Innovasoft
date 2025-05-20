import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    verificarSesion();
    
  }

  void verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final rolLocal = prefs.getString('rol_usuario');

    await Future.delayed(const Duration(seconds: 2));

    // Si el token existe y no ha expirado
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      final rol = decoded['rol'];

      if (rol == 'ADMINISTRADOR') {
        Navigator.pushReplacementNamed(context, '/admin_home');
        return;
      } else if (rol == 'ENTRENADOR') {
        Navigator.pushReplacementNamed(context, '/trainer_home');
        return;
      }
    }

    // Si no hay token, pero hay sesión local como entrenador
    if (rolLocal == 'ENTRENADOR') {
      Navigator.pushReplacementNamed(context, '/trainer_home');
      return;
    }

    // Si no hay sesión válida
    Navigator.pushReplacementNamed(context, '/');
}


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo_indeportes.png'),
              width: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
