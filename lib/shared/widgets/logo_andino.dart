import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Isotipo de Banco Andino: flor de 6 petalos multicolor.
/// Dibujado con CustomPaint para poder rotarlo en el splash/carga.
class LogoAndino extends StatelessWidget {
  final double size;
  const LogoAndino({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FlorPainter()),
    );
  }
}

class _FlorPainter extends CustomPainter {
  static const _petalos = [
    AppColors.logoMagenta,
    AppColors.logoRojo,
    AppColors.logoNaranja,
    AppColors.logoAmarillo,
    AppColors.logoVerde,
    AppColors.logoRosa,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final petalW = r * 0.6;
    final petalH = r * 1.0;

    for (var i = 0; i < _petalos.length; i++) {
      final paint = Paint()
        ..color = _petalos[i]
        ..isAntiAlias = true;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * math.pi / 3);
      final rect = Rect.fromCenter(
        center: Offset(0, -r * 0.42),
        width: petalW,
        height: petalH,
      );
      canvas.drawOval(rect, paint);
      canvas.restore();
    }

    // Centro
    canvas.drawCircle(c, r * 0.24, Paint()..color = Colors.white);
    canvas.drawCircle(c, r * 0.15, Paint()..color = AppColors.logoNaranja);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
