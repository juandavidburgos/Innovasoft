import 'package:basic_flutter/models/user_model.dart';
import 'package:basic_flutter/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';

/// Vista que muestra la lista de eventos almacenados localmente.
class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({super.key});

  @override
  State<ViewUsersPage> createState() => _ViewUsersPage();
}

class _ViewUsersPage extends State<ViewUsersPage> {
  final UserRepository _repo = UserRepository();
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  /// Carga todos los eventos.
  Future<void> _cargarUsuarios() async {
    final users = await _repo.obtenerTodosEntrenadores();
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visualización de entrenadores',
          style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A3E58),
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      backgroundColor: Colors.white,
      body: _users.isEmpty
          ? const Center(child: Text('No hay entrenadores registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Id: ${user.idUsuario}',
                      ),
                      Text(
                        'Rol: ${user.rol}',
                      ),
                      Text(
                        'Contrasena: ${user.contrasena}',
                      ),
                      Text(
                        'Estado: ${user.estado}', style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
