import 'package:flutter/material.dart';

class LogoutIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double alto;
  final double ancho;
  final Color color;
  final IconData icono;
  final OutlinedBorder? shape;
  final MainAxisAlignment alignment; // NUEVO: alineación horizontal del ícono

  const LogoutIconButton({
    super.key,
    required this.onPressed,
    this.alto = 48,
    this.ancho = 48,
    this.color = const Color(0xFF555555),
    this.icono = Icons.logout,
    this.shape,
    this.alignment = MainAxisAlignment.center, // por defecto centrado
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: shape ??
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: alignment,
          children: [
            Icon(
              icono,
              color: Colors.white,
              size: alto * 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
