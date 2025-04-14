import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/indeportes_logo.png',
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  '“Indeportes somos todos”',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
                BotonPrincipal(
                  texto: 'Crear evento',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed(context, '/crear_evento');
                  },
                ),
                const SizedBox(height: 15),
                BotonPrincipal(
                  texto: 'Editar evento',
                  color: Colors.orange,
                  onPressed: () {},
                ),
                const SizedBox(height: 15),
                BotonPrincipal(
                  texto: 'Eliminar/Deshabilitar evento',
                  color: Colors.red,
                  onPressed: () {},
                ),
                const SizedBox(height: 15),
                BotonPrincipal(
                  texto: 'Asignar entrenador',
                  color: Colors.green,
                  onPressed: () {},
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Salir', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BotonPrincipal extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onPressed;

  const BotonPrincipal({
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
        minimumSize: const Size.fromHeight(50),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
