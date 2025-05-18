import 'package:basic_flutter/pages/caracterization/final_register_page.dart';
import 'package:basic_flutter/pages/caracterization/trainer_select_event_page.dart';
import 'package:basic_flutter/pages/home/admin_event_home_page.dart';
import 'package:basic_flutter/pages/home/admin_trainer_home_page.dart';
import 'package:basic_flutter/pages/user_pages/register_user_page.dart';
import 'package:basic_flutter/pages/user_pages/sucsess_reigster_page.dart';
import 'package:basic_flutter/pages/user_pages/sure_logut_page.dart';
import 'package:basic_flutter/splash_screen.dart';
import 'package:flutter/material.dart';
import 'pages/user_pages/login_page.dart';
import 'pages/home/admin_home_page.dart';
import 'pages/create_event/create_event_page.dart';
import 'pages/create_event/view_events_page.dart';
import 'pages/edit_event/edit_event_page.dart';
import 'pages/assign_trainer/trainer_assignment_page.dart';
import 'pages/assign_trainer/view_assignment_page.dart';
import 'pages/edit_assign_trainer/edit_assignment_page.dart';
import 'pages/disable_event/disable_event_page.dart';
import 'pages/home/trainer_home_page.dart';
import 'pages/caracterization/assistence_register_page.dart';
import 'models/event_model.dart';

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
      initialRoute: '/trainer_select_event',
      
      // Aquí defines todas las rutas disponibles en tu app
      routes: {
        'splash': (context) => const SplashScreen(),
        '/': (context) => const LoginPage(),
        '/logout_page': (context) => const ConfirmLogoutPage(),
        '/admin_home': (context) => const AdminHomePage(),
        '/home_admin_trainer' : (context) => const AdminTrainerHomePage(),
        '/home_events': (context) => const AdminEventHomePage(),
        '/trainer_home': (context) => const TrainerHomePage(),
        '/crear_evento': (context) => const CreateEventPage(),
        '/view_event': (context) => const ViewEventsPage(),
        '/edit_event': (context) => const EditEventPage(),
        '/disable_event': (context) => const DisableEventPage(),
        '/assign_trainer': (context) => const TrainerAssignmentPage(),
        '/view_assign': (context) => const ViewAssignmentPage(),
        '/edit_assign': (context) => const EditTrainerAssignmentPage(),
        '/register_asistence': (context) {
            final evento = ModalRoute.of(context)!.settings.arguments as EventModel;
            return AssistenceRegisterPage(evento: evento);
          },
        '/trainer_select_event': (context) => const TrainerSelectEventPage(),
        '/final_register': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            final asistentes = args['asistentes'] as List<Map<String, dynamic>>;
            final evento = args['evento'] as EventModel;

            return FinalRegisterPage(
              asistentes: asistentes,
              evento: evento,
            );
          },
        '/user_register': (context) => const RegisterUserPage(),
        '/success_register_page': (context) => SuccessRegisterPage(),
      },
    );
  }
}
