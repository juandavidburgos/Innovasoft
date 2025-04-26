import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';
import 'success_disable_page.dart';
import 'error_disable_page.dart';

/// Página para confirmar si realmente se desea deshabilitar los eventos seleccionados.
class ConfirmDisablePage extends StatelessWidget {
  final List<int> idsEventos;

  const ConfirmDisablePage({super.key, required this.idsEventos});

  /// Deshabilita los eventos modificando su estado a "deshabilitado".
  Future<void> _deshabilitarEventos(BuildContext context) async {
    final EventRepository repo = EventRepository();

    try {
      for (var id in idsEventos) {
        //final eventos = await repo.obtenerEventos();
        //final evento = eventos.firstWhere((e) => e.idEvento == id);
        /*final eventoDeshabilitado = EventModel(
          idEvento: evento.idEvento,
          nombre: evento.nombre,
          ubicacion: evento.ubicacion,
          fecha: evento.fecha,
          idUsuario: evento.idUsuario,
          estado: 'deshabilitado',
        );*/
        await repo.deshabilitarEvento(id);
      }

      // Si todo salió bien, navegar a la pantalla de éxito
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SuccessDisablePage()),
      );
    } catch (e) {
      // En caso de error, navegar a la pantalla de error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ErrorDisablePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Deshabilitación")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "¿Estás seguro de que deseas deshabilitar los eventos seleccionados?",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Cancelar
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                // Botón Confirmar
                ElevatedButton(
                  onPressed: () => _deshabilitarEventos(context),
                  child: const Text("Confirmar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
