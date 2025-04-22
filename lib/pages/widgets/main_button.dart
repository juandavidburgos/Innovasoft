import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onPressed;

  const MainButton({
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
