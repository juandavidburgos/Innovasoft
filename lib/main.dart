import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_home_page.dart';
import 'pages/create_event_page.dart';
import 'pages/edit_event_page.dart';
import 'pages/trainer_assignment_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      //home: const LoginPage(),
      // Aquí defines la ruta inicial
      initialRoute: '/',
      
      // Aquí defines todas las rutas disponibles en tu app
      routes: {
        '/': (context) => const LoginPage(),
        '/admin_home': (context) => const AdminHomePage(),
        '/crear_evento': (context) => const CreateEventPage(),
        '/edit_event': (context) => const EditEventPage(),
        '/assign_trainer': (context) => const TrainerAssignmentPage(),
      },
    );
  }
}
