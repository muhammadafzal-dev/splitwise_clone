import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One slice of the donut.
class DonutSlice {
  const DonutSlice({required this.value, required this.color});

  final double value;
  final Color color;
}

/// A lightweight donut chart drawn with a [CustomPainter] — no chart package.
/// Shows an optional centre widget (e.g. the total).
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({
    super.key,
    required this.slices,
    this.size = 180,
    this.strokeWidth = 26,
    this.center,
  });

  final List<DonutSlice> slices;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          slices: slices,
          strokeWidth: strokeWidth,
          trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.strokeWidth,
    required this.trackColor,
  });

  final List<DonutSlice> slices;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    const gap = 0.04; // small gap between slices (radians)
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * (2 * math.pi) - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = slice.color;
      canvas.drawArc(rect, start + gap / 2, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.slices != slices ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
