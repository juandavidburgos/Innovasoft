import 'package:basic_flutter/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../widgets/action_button.dart';
import 'package:basic_flutter/pages/home/admin_trainer_home_page.dart';

class DisableUsersPage extends StatefulWidget {
  const DisableUsersPage({super.key});

  @override
  State<DisableUsersPage> createState() => _DisableUsersPage();
}

class _DisableUsersPage extends State<DisableUsersPage> {
  final _repo= UserRepository();
  List<UserModel> entrenadores = [];
  Set<int> seleccionados = {};

  @override
  void initState() {
    super.initState();
    cargarEntrenadores();
  }

  Future<void> cargarEntrenadores() async {
    try {
      final lista = await _repo.obtenerUsuariosRemotos();
      setState(() {
        entrenadores = lista
            .where((e) => e.rol == 'Monitor' && e.estado_monitor == 'activo')
            .toList();
        seleccionados.clear();
      });
    } catch (e) {
      print('Error al cargar entrenadores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar los entrenadores'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  //De manera local
  /*Future<void> cargarEntrenadores() async {
    final lista = await _repo.obtenerUsuariosEntrenadoresActivos(); // Método filtrado por rol
    setState(() {
      entrenadores = lista;
      seleccionados.clear();
    });
  }*/

  Future<void> eliminarSeleccionados() async {
    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un entrenador para continuar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar eliminación', textAlign: TextAlign.center),
        content: Text(
          '¿Eliminar ${seleccionados.length} entrenador(es)?',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          ActionButton(
            text: 'Cancelar',
            color: const Color.fromARGB(255, 134, 134, 134),
            onPressed: () => Navigator.pop(context, false),
          ),
          ActionButton(
            text: 'Eliminar',
            color: Colors.red,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      int fallidos = 0;

      for (final id in seleccionados) {
        final exito = await _repo.deshabilitarEntrenadorRemoto(id);
        if (!exito) fallidos++;
      }

      await cargarEntrenadores();

      if (fallidos == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${seleccionados.length} entrenador(es) deshabilitado(s)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al deshabilitar $fallidos de ${seleccionados.length} entrenador(es)'),
            backgroundColor: Color(0xFF1D5273),
          ),
        );
      }
    }
  }
  //metodo para hacer el proceso local de eliminacion
  /*Future<void> eliminarSeleccionados() async {
    if (seleccionados.isEmpty)  {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un entrendor para continuar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar eliminación',textAlign: TextAlign.center),
        content: Text('¿Eliminar ${seleccionados.length} entrenador(es)?',
          style: TextStyle(fontSize: 16,),
          textAlign: TextAlign.center,
          ),
        actions: [
          ActionButton(
            text: 'Cancelar',
            color: Color.fromARGB(255, 134, 134, 134),
            onPressed: () => Navigator.pop(context, false),
            ),
          ActionButton(
            text: 'Eliminar',
            color: Colors.red,
            onPressed: () => Navigator.pop(context, true),
            ),
        ],
      ),
    );

    if (confirmado == true) {
      for (final id in seleccionados) {
        //local
        await _repo.deshabilitarEntrenador(id);
      }
      cargarEntrenadores();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${seleccionados.length} entrenador(es) deshabilitados(s)')),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 150),
                  Image.asset(
                    'assets/images/logo_indeportes.png',
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '"Indeportes somos todos"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deshabilitar Entrenadores",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
            Expanded(
              child: entrenadores.isEmpty
                  ? const Center(child: Text('No hay entrenadores registrados.'))
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter, 
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8), 
                          itemCount: entrenadores.length,
                          itemBuilder: (context, index) {
                            final user = entrenadores[index];
                            final isChecked = seleccionados.contains(user.id_usuario);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.nombre,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(user.email),
                                          Text('Rol: ${user.rol}'),
                                          Text('Estado: ${user.estado_monitor}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            seleccionados.add(user.id_usuario!);
                                          } else {
                                            seleccionados.remove(user.id_usuario);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Botones inferior
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  text: 'Regresar',
                  ancho: 160,
                  alto: 50,
                  color: Color.fromARGB(255, 134, 134, 134),
                  icono: Icons.arrow_back,
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminTrainerHomePage(),
                    ),
                  ),
                ),
                ActionButton(
                  text: 'Deshabilitar',
                  icono: Icons.disabled_visible,
                  color: Color(0xFF038C65),
                  onPressed: eliminarSeleccionados,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
