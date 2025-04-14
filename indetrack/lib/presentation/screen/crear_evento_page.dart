import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:lib/utils/conexion.dart';

class CrearEventoPage extends StatefulWidget {
  const CrearEventoPage({super.key});

  @override
  State<CrearEventoPage> createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  DateTime? fechaSeleccionada;

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
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear evento',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                buildCampo(
                  label: 'Nombre',
                  hint: 'Ingrese el nombre del evento',
                  controller: nombreController,
                ),
                buildCampo(
                  label: 'Descripción',
                  hint: 'Ingrese la descripción del evento',
                  controller: descripcionController,
                ),
                buildCampo(
                  label: 'Ubicación',
                  hint: 'Ingrese la ubicación del evento',
                  controller: ubicacionController,
                ),
                buildCampoFecha(context),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BotonAccion(
                      texto: 'CREAR',
                      color: Colors.green,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (fechaSeleccionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor seleccione una fecha')),
                            );
                            return;
                          }

                          // Aquí puedes manejar el envío de datos.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Evento creado exitosamente')),
                          );
                        }
                      },
                    ),
                    BotonAccion(
                      texto: 'VOLVER',
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
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

  Widget buildCampo({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
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
              hintText: hint,
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

  Widget buildCampoFecha(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _seleccionarFecha(context),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Seleccione la fecha',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              child: Text(
                fechaSeleccionada != null
                    ? DateFormat('dd-MM-yyyy').format(fechaSeleccionada!)
                    : 'Seleccione la fecha',
                style: TextStyle(
                  color: fechaSeleccionada != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }
}

class BotonAccion extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onPressed;

  const BotonAccion({
    super.key,
    required this.texto,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 45),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
