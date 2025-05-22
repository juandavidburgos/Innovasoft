import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../widgets/logout_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});
  @override
  State<TrainerHomePage> createState() => _TrainerHomePage();
  
}

class _TrainerHomePage extends State<TrainerHomePage> {
  String nombreUsuario = 'Cargando...';
  int usuarioId = -1;
  String rolUsuario = '';
  String emailUsuario = '';
  String estado = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosSesion();
  }

  Future<void> _cargarDatosSesion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('id_usuario') ?? -1;
      nombreUsuario = prefs.getString('nombre_usuario') ?? 'Desconocido';
      emailUsuario = prefs.getString('email_usuario') ?? 'Sin correo';
      rolUsuario = prefs.getString('rol_usuario') ?? 'Sin rol';
      estado = prefs.getString('estado') ?? 'Inactivo';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón logout (arriba a la izquierda)
            Positioned(
              top: 10,
              left: -20,
              child: LogoutIconButton(
                ancho: 65,
                alto: 40,
                color: const Color.fromARGB(255, 143, 3, 3),
                icono: Icons.logout,
                alignment: MainAxisAlignment.end,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/logout_page');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 20),

                    const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 30),

                    Text(
                      'Bienvenido, $nombreUsuario!\nRol: $rolUsuario \n Estado: $estado' ,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                    const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 30),
                    const SizedBox(height: 20),

                    MainButton(
                      texto: 'Registrar Asistentes',
                      color: const Color.fromARGB(255, 232, 78, 17),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/trainer_select_event');
                      },
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

