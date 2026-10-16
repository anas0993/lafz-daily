import 'package:flutter/material.dart';
import 'wood_theme.dart';

/// Slow, subtle animated gradient backdrop (emerald → cream drift).
///
/// Wiring (game_screen.dart / home_screen.dart — owned by other
/// workstreams): wrap the Scaffold body with it, e.g.
///
///   body: AnimatedBackground(
///     child: SafeArea(
///       child: ... existing body ...,
///     ),
///   ),
///
/// Cheap by design: a single AnimationController drives one
/// AnimatedBuilder, and only the background DecoratedBox repaints —
/// [child] is passed through AnimatedBuilder's cached `child` slot and is
/// never rebuilt by the animation.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    duration: const Duration(seconds: 14),
    vsync: this,
  )..repeat(reverse: true);

  static const _emeraldTint = Color(0xFFDDEEDF);
  static const _creamWarm = Color(0xFFF7ECD2);

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drift,
      child: widget.child,
      builder: (context, child) {
        final t = _drift.value; // 0 → 1 → 0, very slow
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 0.5 * t, -1.0),
              end: Alignment(1.0 - 0.5 * t, 1.0),
              colors: [
                Color.lerp(WoodTheme.cream, _emeraldTint, t)!,
                Color.lerp(_creamWarm, WoodTheme.cream, t)!,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
