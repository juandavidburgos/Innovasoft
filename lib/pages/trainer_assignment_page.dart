import 'package:flutter/material.dart';
import 'widgets/action_button.dart';

class TrainerAssignmentPage extends StatefulWidget {
  const TrainerAssignmentPage({super.key});

  @override
  State<TrainerAssignmentPage> createState() => _TrainerAssignmentPageState();
}

class _TrainerAssignmentPageState extends State<TrainerAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedTrainer;
  String? selectedEvent;

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
                const Text('Asignar Entrenador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Dropdown para seleccionar entrenador (vacío por ahora)
                DropdownButtonFormField<String>(
                  value: selectedTrainer,
                  items: const [], // Se llenará más adelante
                  onChanged: (String? value) {
                    setState(() {
                      selectedTrainer = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Entrenador',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown para seleccionar evento (vacío por ahora)
                DropdownButtonFormField<String>(
                  value: selectedEvent,
                  items: const [], // Se llenará más adelante
                  onChanged: (String? value) {
                    setState(() {
                      selectedEvent = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Evento',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: 'ASIGNAR',
                      color: Colors.green,
                      onPressed: _assignTrainer,
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

  void _assignTrainer() {
    if (selectedTrainer != null && selectedEvent != null) {
      Navigator.pushNamed(context, '/trainer_assigned');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un entrenador y un evento')),
      );
    }
  }
}
