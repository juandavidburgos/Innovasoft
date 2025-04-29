import 'package:basic_flutter/splash_screen.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home/admin_home_page.dart';
import 'pages/create_event/create_event_page.dart';
import 'pages/edit_event/edit_event_page.dart';
import 'pages/assign_trainer/trainer_assignment_page.dart';
import 'pages/disable_event/disable_event_page.dart';
import 'pages/home/trainer_home_page.dart';

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
      initialRoute: '/admin_home',
      
      // Aquí defines todas las rutas disponibles en tu app
      routes: {
        'splash': (context) => const SplashScreen(),
        '/': (context) => const LoginPage(),
        '/admin_home': (context) => const AdminHomePage(),
        '/trainer_home': (context) => const TrainerHomePage(),
        '/crear_evento': (context) => const CreateEventPage(),
        '/edit_event': (context) => const EditEventPage(),
        '/disable_event': (context) => const DisableEventPage(),
        '/assign_trainer': (context) => const TrainerAssignmentPage(),
        
      },
    );
  }
}
