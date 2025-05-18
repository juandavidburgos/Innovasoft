import 'package:basic_flutter/pages/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePage();
  
}
class _AdminHomePage extends State<AdminHomePage> {

  String nombreUsuario = 'Cargando...';
  int usuarioId = -1;
  String rolUsuario = '';
  String emailUsuario = '';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón logout (arriba a la derecha)
            Positioned(
              top: 10, // sobresale hacia arriba
              left: -20, // sobresale hacia la izquierda
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

            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 20),
                    Text(
                      'Bienvenido, $nombreUsuario!\nRol: $rolUsuario',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Divider(thickness: 1.5, color: Color(0xFFCCCCCC), height: 20),
                  ]
              ),
            ),

            // Contenido principal alineado arriba
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // Puedes ajustar vertical
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/logo_indeportes.png',
                      width: 250,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '“Indeportes somos todos”',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),
                    MainButton(
                      texto: 'Gestión de eventos',
                      color: const Color.fromARGB(255, 232, 78, 17),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/home_events');
                      },
                    ),
                    const SizedBox(height: 15),
                    MainButton(
                      texto: 'Asignación de entrenadores',
                      color: const Color.fromARGB(255, 16, 88, 146),
                      ancho: 260,
                      onPressed: () {
                        Navigator.pushNamed(context, '/home_admin_trainer');
                      },
                    ),
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