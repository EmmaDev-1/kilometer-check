import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Dibuja una llanta estilizada por fases:
/// anillo exterior → dibujo de piso → rin con rayos → acento amarillo.
///
/// Cada campo `*Progress` va de 0 a 1 y controla su propia fase.
class TireRingPainter extends CustomPainter {
  const TireRingPainter({
    required this.ringProgress,
    required this.treadProgress,
    required this.hubProgress,
    required this.accentProgress,
  });

  final double ringProgress;
  final double treadProgress;
  final double hubProgress;
  final double accentProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - 8;

    canvas.save();
    // Rotación sutil mientras el anillo se dibuja.
    canvas.translate(center.dx, center.dy);
    canvas.rotate((1 - ringProgress) * 0.9);
    canvas.scale(0.92 + 0.08 * ringProgress);
    canvas.translate(-center.dx, -center.dy);

    _paintRing(canvas, center, radius);
    _paintTreads(canvas, center, radius);
    _paintHub(canvas, center, radius);
    _paintAccent(canvas, center, radius);

    canvas.restore();
  }

  void _paintRing(Canvas canvas, Offset center, double radius) {
    if (ringProgress <= 0) return;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = AppColors.blueLight;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      ringProgress * 2 * math.pi,
      false,
      paint,
    );
  }

  void _paintTreads(Canvas canvas, Offset center, double radius) {
    if (treadProgress <= 0) return;
    const int tickCount = 8;
    final Paint paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < tickCount; i++) {
      // Aparición escalonada de cada tick.
      final double tickT = ((treadProgress * tickCount) - i)
          .clamp(0.0, 1.0)
          .toDouble();
      if (tickT == 0) continue;

      final double angle = -math.pi / 2 + (2 * math.pi / tickCount) * i;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset from = center + direction * (radius - 16);
      final Offset to = center + direction * (radius - 16 + 8 * tickT);

      paint.color = AppColors.text300.withValues(alpha: 0.7 * tickT);
      canvas.drawLine(from, to, paint);
    }
  }

  void _paintHub(Canvas canvas, Offset center, double radius) {
    if (hubProgress <= 0) return;
    final double rimRadius = radius * 0.52;

    final Paint rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.text100.withValues(alpha: hubProgress);
    canvas.drawCircle(center, rimRadius * hubProgress, rimPaint);

    // Rayos del rin.
    const int spokeCount = 5;
    final Paint spokePaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.text100.withValues(alpha: hubProgress);

    for (int i = 0; i < spokeCount; i++) {
      final double angle = -math.pi / 2 + (2 * math.pi / spokeCount) * i;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * 8,
        center + direction * rimRadius * 0.82 * hubProgress,
        spokePaint,
      );
    }

    final Paint hubPaint = Paint()
      ..color = AppColors.text100.withValues(alpha: hubProgress);
    canvas.drawCircle(center, 5 * hubProgress, hubPaint);
  }

  void _paintAccent(Canvas canvas, Offset center, double radius) {
    if (accentProgress <= 0) return;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = AppColors.yellow;

    // Segmento amarillo que recorre el anillo y se asienta arriba.
    final double travel = accentProgress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + travel,
      math.pi * 0.22 * accentProgress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TireRingPainter oldDelegate) =>
      oldDelegate.ringProgress != ringProgress ||
      oldDelegate.treadProgress != treadProgress ||
      oldDelegate.hubProgress != hubProgress ||
      oldDelegate.accentProgress != accentProgress;
}
