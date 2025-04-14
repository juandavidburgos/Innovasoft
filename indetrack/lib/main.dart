import 'package:flutter/material.dart';
import 'presentation/screen/home_page.dart';
import 'presentation/screen/login_page.dart';
import 'presentation/screen/crear_evento_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indeportes Cauca',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // <- esta es la pantalla inicial
      routes: {
        '/': (context) => const LoginPage(),        // <- CAMBIA esto a LoginPage
        '/home': (context) => const HomePage(),     // <- ruta a home
        '/crear_evento': (context) => const CrearEventoPage(),
      },
    );
  }
}


