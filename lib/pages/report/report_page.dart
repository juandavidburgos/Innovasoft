import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../../models/event_model.dart';
import '../../repositories/forms_repository.dart';
import '../../repositories/event_repository.dart';
import 'package:path_provider/path_provider.dart';

class GenerateReportePage extends StatefulWidget {
  const GenerateReportePage({super.key});

  @override
  State<GenerateReportePage> createState() => _GenerateReportePageState();
}

class _GenerateReportePageState extends State<GenerateReportePage> {
  final FormsRepository _repo = FormsRepository();
  final EventRepository eventRepo = EventRepository();
  List<EventModel> _eventos = [];
  EventModel? _eventoSeleccionado;
  bool _descargando = false;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    //obtener local
    print('Cargando eventos...');
    //final eventos = await eventRepo.obtenerEventos();
    //obtener remoto
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _eventos =  eventos;
    });
    print('Eventos cargados: ${_eventos.length}');
  }
  /*Future<void> _cargarEventos() async {
    try {
      final eventos = await eventRepo.obtenerEventosRemotos();
      setState(() {
        _eventos = eventos.where((e) => e.estado == 'activo').toList();
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar eventos')),
        );
      }
    }
  }*/

  Future<void> _generarReporte() async {
    if (_eventoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un evento')),
      );
      return;
    }

    setState(() => _descargando = true);

    try {
      File? archivo = await _repo.descargarReporteExcel(_eventoSeleccionado!.id_evento!);
      //revisar
      if (archivo != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte descargado con éxito')),
        );
        try{  
          // Intentar abrir el archivo descargado
          print('Abriendo archivo: ${archivo.path}');
          //await OpenFile.open(archivo.path);
          // Usar el paquete open_file para abrir el archivo
         await _guardarYAbrirReporte(archivo);
        }
        catch(e){
          print('Error al abrir el archivo: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el reporte')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al generar reporte')),
        );
      }
    } finally {
      setState(() => _descargando = false);
    }
  }

  /// Guarda el archivo descargado en una ubicación específica y lo abre.
  /// Dependiendo de la plataforma, guarda el archivo en la carpeta de Descargas o en Documentos.
  Future<void> _guardarYAbrirReporte(File downloadedFile) async {
    String platformSpecificMessage = '';

    try {
      Directory? baseDirectory;
      if (Platform.isAndroid) {
        baseDirectory = await getDownloadsDirectory();
        platformSpecificMessage = 'carpeta de Descargas';
      } else if (Platform.isIOS) {
        baseDirectory = await getApplicationDocumentsDirectory();
        platformSpecificMessage = 'carpeta de Documentos de la app';
      } else {
        baseDirectory = await getApplicationDocumentsDirectory();
        platformSpecificMessage = 'carpeta de Documentos';

      }

      if (baseDirectory == null) {
        throw Exception('No se pudo acceder al directorio de almacenamiento del dispositivo.');
      }
      
      // Asegúrate de que el directorio exista
      if (!await baseDirectory.exists()) {
        await baseDirectory.create(recursive: true);
      }

      final String fileName = 'Reporte_Evento_${_eventoSeleccionado!.id_evento!}.xlsx';
      final archivoFinal = File('${baseDirectory.path}/$fileName');

      await downloadedFile.copy(archivoFinal.path);

      if (!await archivoFinal.exists()) {
        throw Exception('El archivo no se guardó correctamente en la ubicación final.');
      }

      if (context.mounted) {
        print('Archivo guardado en: ${archivoFinal.path}');
        try {
          await OpenFile.open(archivoFinal.path);
        } catch (e) {
          print('Error al intentar abrir el archivo con OpenFile: $e');
        }
      }
    } catch (e) {
      if (context.mounted) {
        print('Error en _guardarYAbrirReporte: $e');
      }
    } finally {
      if (await downloadedFile.exists()) {
        await downloadedFile.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Reporte Excel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF1A3E58),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione un evento:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventModel>(
              isExpanded: true,
              value: _eventoSeleccionado,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Evento',
              ),
              items: _eventos.map((evento) {
                return DropdownMenuItem<EventModel>(
                  value: evento,
                  child: Text(evento.nombre ?? 'Evento sin nombre'),
                );
              }).toList(),
              onChanged: (evento) {
                setState(() {
                  _eventoSeleccionado = evento;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3E58),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _descargando ? null : _generarReporte,
                icon: _descargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download),
                label: Text(_descargando ? 'Generando...' : 'Generar Reporte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/event_model.dart';
import '../../repositories/forms_repository.dart';
import '../../repositories/event_repository.dart';

class GenerateReportePage extends StatefulWidget {
  const GenerateReportePage({super.key});

  @override
  State<GenerateReportePage> createState() => _GenerateReportePageState();
}

class _GenerateReportePageState extends State<GenerateReportePage> {
  final FormsRepository _repo = FormsRepository();
  final EventRepository event_repo = EventRepository();
  List<EventModel> _eventos = [];
  EventModel? _eventoSeleccionado;
  bool _descargando = false;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final eventos = await event_repo.obtenerEventosRemotos();
      setState(() {
        _eventos = eventos.where((e) => e.estado == 'activo').toList();
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar eventos!')),
        );
      }
    }
  }

  Future<void> _generarReporte() async {
    if (_eventoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un evento')),
      );
      return;
    }

    setState(() => _descargando = true);

    try {
      File? archivo = await _repo.descargarReporteExcel(_eventoSeleccionado!.id_evento!);//revisar

      if (archivo != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte descargado con éxito')),
        );
        await OpenFile.open(archivo.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el reporte')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al generar reporte')),
        );
      }
    } finally {
      setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Reporte Excel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<EventModel>(
              isExpanded: true,
              value: _eventoSeleccionado,
              hint: const Text('Selecciona un evento'),
              items: _eventos.map((evento) {
                return DropdownMenuItem<EventModel>(
                  value: evento,
                  child: Text(evento.nombre ?? 'Evento sin nombre'),
                );
              }).toList(),
              onChanged: (evento) {
                setState(() {
                  _eventoSeleccionado = evento;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _descargando ? null : _generarReporte,
              icon: const Icon(Icons.download),
              label: _descargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}*/