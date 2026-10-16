import 'package:flutter/material.dart';

/// Placeholder ad slot shown in the clean (no-ads) build.
///
/// Each slot renders as a clearly-marked, subtle, debug-style dashed box
/// labelled "AD SLOT: <name>" so QA and the parent can see exactly where a
/// real ad will appear. When real ads are enabled, this widget is replaced
/// 1:1 by a real banner ad.
///
/// // TODO(ads): Replace AdSlot with real BannerAd here.
///
/// Insert points for the parent (do not edit existing screens in this
/// workstream; these are the wiring instructions):
///   1. Home screen bottom — below the main content column.
///   2. Game/puzzle screen bottom — below the keyboard.
///   3. Game-over/win dialog — above/below the result actions.
///   4. Scramble screen bottom — below the main content column.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key, required this.slotName});

  /// Debug name of the slot, e.g. 'home_bottom', 'game_bottom',
  /// 'gameover_dialog', 'scramble_bottom'.
  final String slotName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: scheme.onSurface.withValues(alpha: 0.35),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Text(
            'AD SLOT: $slotName',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed rounded-rectangle border painter.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;
  static const double _dash = 6;
  static const double _gap = 4;
  static const double _radius = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rect);
    double distance = 0;
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      while (distance < length) {
        final start = distance;
        final end = (distance + _dash).clamp(0.0, length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
