import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/local_service.dart';

/// Vista que permite al usuario deshabilitar un evento activo.
/// El evento seleccionado cambiará su estado de 'activo' a 'inactivo'.
class DisableEventPage extends StatefulWidget {
  const DisableEventPage({super.key});

  @override
  State<DisableEventPage> createState() => _DisableEventPageState();
}

class _DisableEventPageState extends State<DisableEventPage> {
  final LocalService _service = LocalService();

  List<EventModel> _eventosActivos = [];
  EventModel? _eventoSeleccionado;

  /// Obtiene la lista de eventos activos al cargar la vista.
  @override
  void initState() {
    super.initState();
    _cargarEventosActivos();
  }

  /// Consulta los eventos activos desde el servicio local.
  Future<void> _cargarEventosActivos() async {
    final eventos = await _service.getEventos(soloActivos: true);
    setState(() {
      _eventosActivos = eventos;
    });
  }

  /// Muestra un cuadro de diálogo de confirmación para deshabilitar el evento seleccionado.
  void _confirmarDeshabilitacion() {
    if (_eventoSeleccionado == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de que desea deshabilitar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await _service.deshabilitarEvento(_eventoSeleccionado!.idEvento!);
              Navigator.pop(context); // Cierra el diálogo
              _mostrarSnackBar('Evento deshabilitado correctamente');
              _cargarEventosActivos(); // Recarga la lista actualizada
              setState(() {
                _eventoSeleccionado = null;
              });
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje emergente (Snackbar) en la pantalla.
  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deshabilitar Evento')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown para seleccionar el evento activo
            DropdownButtonFormField<EventModel>(
              decoration: const InputDecoration(labelText: 'Seleccione un evento activo'),
              items: _eventosActivos.map((evento) {
                return DropdownMenuItem<EventModel>(
                  value: evento,
                  child: Text('${evento.nombre} - ${evento.fecha}'),
                );
              }).toList(),
              onChanged: (evento) {
                setState(() {
                  _eventoSeleccionado = evento;
                });
              },
              value: _eventoSeleccionado,
            ),

            const SizedBox(height: 20),

            // Botón para iniciar el proceso de deshabilitación
            ElevatedButton(
              onPressed: _eventoSeleccionado != null ? _confirmarDeshabilitacion : null,
              child: const Text('Deshabilitar'),
            ),
          ],
        ),
      ),
    );
  }
}
