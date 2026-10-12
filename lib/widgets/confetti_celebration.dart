import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight confetti celebration shown on wins.
/// No external packages — pure Flutter CustomPainter.
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key, this.duration = const Duration(seconds: 3)});

  final Duration duration;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final _random = Random();

  static const _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 120; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.3,
        vy: 0.4 + _random.nextDouble() * 0.6,
        size: 4 + _random.nextDouble() * 6,
        color: _colors[_random.nextInt(_colors.length)],
        rotation: _random.nextDouble() * 3.14159 * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {
            for (final p in _particles) {
              p.x += p.vx * 0.016;
              p.y += p.vy * 0.016;
              p.rotation += p.rotationSpeed * 0.016;
            }
          }))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_particles),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, rotation, rotationSpeed;
  final Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.y > 1.1) continue;
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
