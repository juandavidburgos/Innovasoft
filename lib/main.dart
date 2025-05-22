import 'package:basic_flutter/pages/caracterization/final_register_page.dart';
import 'package:basic_flutter/pages/caracterization/trainer_select_event_page.dart';
import 'package:basic_flutter/pages/home/admin_event_home_page.dart';
import 'package:basic_flutter/pages/home/admin_trainer_home_page.dart';
import 'package:basic_flutter/pages/user_pages/view_users.dart';
import 'package:basic_flutter/pages/user_pages/disable_users_page.dart';
import 'package:basic_flutter/pages/user_pages/register_user_page.dart';
import 'package:basic_flutter/pages/user_pages/sucsess_reigster_page.dart';
import 'package:basic_flutter/pages/user_pages/sure_logut_page.dart';
import 'package:basic_flutter/services/local_data_service.dart';
import 'package:basic_flutter/services/remote_data_service.dart';
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
import 'pages/caracterization/trainer_select_permanent_event_page.dart';
import 'pages/caracterization/check_assistant_page.dart';
import 'models/event_model.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Inicializar la BD una sola vez
  //await LocalDataService.db.deleteDB();

  //Inicializar la BD una sola vez
  await LocalDataService.db.database;

  // 👤 Crea el administrador temporal (si no existe)
  await LocalDataService.db.crearAdminTemporal();
  // Inicializas tus servicios
  LocalDataService.db.iniciarEscuchaDeConexion(); 

  //Sincronizar usuarios
  await _verificarYSincronizar();

  runApp(const MyApp());
}

Future<void> _verificarYSincronizar() async {
  if (await LocalDataService.db.hayInternet()) {
    await RemoteDataService.dbR.sincronizarHaciaServidor();
  }
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
      // ruta inicial
      initialRoute: 'splash',
      
      // Aquí defines todas las rutas disponibles en tu app
      routes: {

        // Rutas de inicio de sesión
        'splash': (context) => const SplashScreen(),
        '/': (context) => const LoginPage(),
        '/logout_page': (context) => const ConfirmLogoutPage(),

        //Rutas home del administrador
        '/admin_home': (context) => const AdminHomePage(),
        '/home_admin_trainer' : (context) => const AdminTrainerHomePage(),
        '/home_events': (context) => const AdminEventHomePage(),

        //Rutas de gestión de eventos
        '/crear_evento': (context) => const CreateEventPage(),
        '/view_event': (context) => const ViewEventsPage(),
        '/edit_event': (context) => const EditEventPage(),
        '/disable_event': (context) => const DisableEventPage(),

        //Rutas de gestión de entrenadores
        '/assign_trainer': (context) => const TrainerAssignmentPage(),
        '/view_assign': (context) => const ViewAssignmentPage(),
        '/edit_assign': (context) => const EditTrainerAssignmentPage(),

        //Rutas para el entrenador
        '/trainer_home': (context) => const TrainerHomePage(),
        '/register_asistence': (context) {
            final evento = ModalRoute.of(context)!.settings.arguments as EventModel;
            return AssistenceRegisterPage(evento: evento);
          },
        '/trainer_select_event': (context) => const TrainerSelectEventPage(),
        '/trainer_select_permanent_event': (context) => const TrainerSelectPermanentEventPage(),
        '/final_register': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

            final evento = args['evento'] as EventModel;
            final int usuarioId = args['usuario_id'] as int;
            final int formularioId = args['formulario_id'] as int;

            return FinalRegisterPage(
              evento: evento,
              usuario_id: usuarioId,
              formulario_id: formularioId,
            );
          },
        '/check_assistant': (context) {
          final evento = ModalRoute.of(context)!.settings.arguments as EventModel;
          return CheckAssistantPage(evento: evento);
        },

        //Rutas para la autenticación de usuarios
        '/user_register': (context) => const RegisterUserPage(),
        '/success_register_page': (context) => SuccessRegisterPage(),
        '/view_users': (context) => ViewUsersPage(),
        '/disable_users': (context) => DisableUsersPage(),
      },
    );
  }
}
