import 'package:basic_flutter/pages/widgets/action_button.dart';
import 'package:flutter/material.dart';
import '../widgets/main_button.dart';

class AdminEventHomePage extends StatelessWidget {
  const AdminEventHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo_indeportes.png',
                  width: 250,
                ),
                const SizedBox(height: 30),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
                MainButton(
                  texto: 'Crear evento',
                  color: Color(0xFF1A3E58),
                  icono: Icons.add_circle_outline,
                  ancho: 280,
                  onPressed: () {
                    Navigator.pushNamed(context,'/crear_evento');
                  
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Editar evento',
                  color: Color(0xFF1A3E58),
                  icono: Icons.edit_outlined,
                  ancho: 280,
                  onPressed: () {
                    //Redigir a la pagina
                    Navigator.pushNamed(context, '/edit_event');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Visualizar eventos creados',
                  color: Color(0xFF1A3E58),
                  icono: Icons.visibility_outlined,
                  ancho: 280,
                  onPressed: () {
                    Navigator.pushNamed(context,'/view_event');
                  },
                ),
                const SizedBox(height: 15),
                MainButton(
                  texto: 'Deshabilitar evento',
                  color: Color(0xFF1A3E58),
                  icono: 	Icons.block,
                  ancho: 280,
                  onPressed: () {Navigator.pushNamed(context, '/disable_event');},
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ActionButton(
                    text: 'Regresar',
                    color: Color.fromARGB(255, 134, 134, 134),
                    icono: Icons.arrow_back,
                    ancho: 145,
                    alto: 48,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/admin_home');
                      },
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