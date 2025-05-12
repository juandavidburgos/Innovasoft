import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/event_model.dart';
import '../../repositories/event_repository.dart';
import '../widgets/action_button.dart';
import 'dart:convert';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;

  String? selectedEvent;
  String? selectedMunicipio;
  final EventRepository _repo = EventRepository();
  List<EventModel> _eventos = [];
  List<String> municipios = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
    _cargarMunicipios();
  }

  Future<void> _cargarEventos() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      _eventos = eventos.where((evento) => evento.estado == 'activo').toList();
    });
  }

  Future<void> _cargarMunicipios() async {
    final String response = await rootBundle.loadString('assets/utils/municipios_cauca.json');
    final List<dynamic> data = List.from(jsonDecode(response));
    setState(() {
      municipios = data.map((e) => e.toString()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/logo_indeportes.png', width: 200),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('Editar Evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildDropdownField(),
                const SizedBox(height: 20),
                _buildField(label: 'Nombre', controller: nameController),
                _buildMunicipioDropdown(),
                _buildField(label: 'Descripción', controller: descripcionController),
                _buildDateTimePicker(context, 'Fecha y hora de inicio', true),
                _buildDateTimePicker(context, 'Fecha y hora de fin', false),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'ACTUALIZAR',
                      color: Color(0xFF038C65),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            fechaHoraInicio != null &&
                            fechaHoraFin != null &&
                            selectedEvent != null &&
                            selectedMunicipio != null) {
                          final idEvento = int.parse(selectedEvent!);
                          final eventoActualizado = EventModel(
                            idEvento: idEvento,
                            nombre: nameController.text.trim(),
                            descripcion: descripcionController.text.trim(),
                            fechaHoraInicio: fechaHoraInicio!,
                            fechaHoraFin: fechaHoraFin!,
                            ubicacion: selectedMunicipio!,
                            estado: 'activo',
                          );

                          final result = await _repo.actualizarEvento(eventoActualizado);

                          if (result > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Evento actualizado con éxito')),
                            );
                            await _cargarEventos();
                            setState(() {
                              selectedEvent = null;
                              nameController.clear();
                              locationController.clear();
                              descripcionController.clear();
                              fechaHoraInicio = null;
                              fechaHoraFin = null;
                              selectedMunicipio = null;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al actualizar el evento')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor completa todos los campos')),
                          );
                        }
                      },
                    ),
                    ActionButton(
                      text: 'VOLVER',
                      color: Color(0xFF1D5273),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar evento',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _eventos.map((evento) {
        return DropdownMenuItem<String>(
          value: evento.idEvento.toString(),
          child: Text(evento.nombre),
        );
      }).toList(),
      value: selectedEvent,
      onChanged: (value) {
        setState(() {
          selectedEvent = value;
          final evento = _eventos.firstWhere((e) => e.idEvento.toString() == value);
          nameController.text = evento.nombre;
          descripcionController.text = evento.descripcion ?? '';
          locationController.text = evento.ubicacion;
          selectedMunicipio = evento.ubicacion;
          fechaHoraInicio = evento.fechaHoraInicio;
          fechaHoraFin = evento.fechaHoraFin;
        });
      },
    );
  }

  Widget _buildMunicipioDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Selecciona un municipio',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            value: selectedMunicipio,
            items: municipios.map((municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(municipio),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMunicipio = value;
                locationController.text = value!;
              });
            },
            validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
            decoration: InputDecoration(
              hintText: 'Ingrese $label',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, String label, bool isInicio) {
    final selectedDateTime = isInicio ? fechaHoraInicio : fechaHoraFin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDateTime(context, isInicio),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              child: Text(
                selectedDateTime != null
                    ? DateFormat('dd-MM-yyyy HH:mm').format(selectedDateTime)
                    : 'Selecciona fecha y hora',
                style: TextStyle(
                  color: selectedDateTime != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isInicio) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          if (isInicio) {
            fechaHoraInicio = dateTime;
          } else {
            fechaHoraFin = dateTime;
          }
        });
      }
    }
  }
}

/*class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? selectedDate;

  String? selectedEvent; // Para Dropdown
  String? selectedMunicipio; // Para Dropdown de municipios
  final EventRepository _repo = EventRepository();
  List<EventModel> _eventos = [];
  List<String> municipios = []; // Lista para almacenar los municipios

  @override
  void initState() {
    super.initState();
    _cargarEventos();
    _cargarMunicipios(); // Cargar municipios
  }

  /// Carga todos los eventos activos.
  Future<void> _cargarEventos() async {
    final eventos = await _repo.obtenerEventos();
    setState(() {
      // Filtrar los eventos activos (suponiendo que 'estado' es una propiedad que indica si el evento está activo)
      _eventos = eventos.where((evento) => evento.estado == 'activo').toList();
    });
  }

  /// Carga los municipios desde el archivo JSON
  Future<void> _cargarMunicipios() async {
    final String response = await rootBundle.loadString('assets/utils/municipios_cauca.json');
    final List<dynamic> data = List.from(jsonDecode(response));
    setState(() {
      municipios = data.map((e) => e.toString()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/indeportes_logo.png', width: 200),
                const SizedBox(height: 10),
                const Text('“Indeportes somos todos”', style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('Editar Evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildDropdownField(), // Dropdown con eventos activos

                const SizedBox(height: 20),

                _buildField(label: 'Nombre', controller: nameController),
                _buildMunicipioDropdown(), // Dropdown con municipios
                _buildDateField(context),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'ACTUALIZAR',
                      color: Colors.green,
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            selectedDate != null &&
                            selectedEvent != null &&
                            selectedMunicipio != null) {
                          final idEvento = int.parse(selectedEvent!);
                          final eventoActualizado = EventModel(
                            idEvento: idEvento,
                            nombre: nameController.text.trim(),
                            fecha: selectedDate!,
                            ubicacion: selectedMunicipio!, // Aquí se usa el municipio seleccionado
                            estado: 'activo',
                          );

                          final result = await _repo.actualizarEvento(eventoActualizado);

                          if (result > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Evento actualizado con éxito')),
                            );
                            await _cargarEventos(); // recargar lista
                            setState(() {
                              selectedEvent = null;
                              nameController.clear();
                              locationController.clear();
                              selectedDate = null;
                              selectedMunicipio = null; // Limpiar municipio seleccionado
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al actualizar el evento')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor completa todos los campos')),
                          );
                        }
                      },
                    ),
                    ActionButton(
                      text: 'VOLVER',
                      color: Colors.blue,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar evento',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: _eventos.map((evento) {
        return DropdownMenuItem<String>(
          value: evento.idEvento.toString(), // o evento.nombre si prefieres
          child: Text(evento.nombre),
        );
      }).toList(),
      value: selectedEvent,
      onChanged: (value) {
        setState(() {
          selectedEvent = value;
          final eventoSeleccionado = _eventos.firstWhere((e) => e.idEvento.toString() == value);
          nameController.text = eventoSeleccionado.nombre;
          locationController.text = eventoSeleccionado.ubicacion;
          selectedDate = eventoSeleccionado.fecha;
          selectedMunicipio = eventoSeleccionado.ubicacion; // Actualizar municipio seleccionado
        });
      },
    );
  }

  Widget _buildMunicipioDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Selecciona un municipio',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            value: selectedMunicipio,
            items: municipios.map((municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(municipio),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMunicipio = value;
                locationController.text = value!;
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Este campo es obligatorio'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
            decoration: InputDecoration(
              hintText: 'Ingrese $label',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Selecciona una fecha',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              child: Text(
                selectedDate != null
                    ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                    : 'Selecciona una fecha',
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}*/