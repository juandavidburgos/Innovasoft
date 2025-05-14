import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final IconData? icono;
  final double? ancho;
  final double? alto;

  const ActionButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.icono,
    this.ancho, // ancho personalizado opcional
    this.alto = 50, // alto por defecto
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho, // si es null, toma el ancho natural del contenido
      height: alto,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 20, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
