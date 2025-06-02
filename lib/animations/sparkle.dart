import 'package:flutter/material.dart';
import 'dart:math';

class Sparkle {
  Offset position;
  double size;
  double delay;

  Sparkle(this.position, this.size, this.delay);

  static Sparkle random() {
    final rnd = Random();
    return Sparkle(
      Offset(rnd.nextDouble(), rnd.nextDouble()),
      rnd.nextDouble() * 10 + 5,
      rnd.nextDouble(),
    );
  }
}

class SparklePainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double progress;

  SparklePainter(this.sparkles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var sparkle in sparkles) {
      final double p = ((progress - sparkle.delay + 1.0) % 1.0);
      final double opacity = (1.0 - (p - 0.5).abs() * 2).clamp(0.0, 1.0);
      final double scaledSize = sparkle.size * opacity;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
          Offset(sparkle.position.dx * size.width,
              sparkle.position.dy * size.height),
          scaledSize,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}