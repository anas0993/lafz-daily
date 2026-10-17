import 'package:flutter/material.dart';
import 'wood_theme.dart';

/// Full-screen illustrated scene background (v4.2).
///
/// Replaces [AnimatedBackground] on the three hero screens (home, game,
/// scramble). Layers, bottom to top:
///   1. the PNG artwork, BoxFit.cover (handles any aspect ratio),
///   2. a readability scrim: soft top-to-bottom cream/emerald gradient at
///      low opacity so tiles, buttons and text pop over the art,
///   3. [child] — the screen's actual UI.
///
/// The PNGs ship at ~2-3 MB each; Flutter decodes them once and caches.
class SceneBackground extends StatelessWidget {
  const SceneBackground({
    super.key,
    required this.asset,
    required this.child,
    this.scrimOpacity = 0.55,
  });

  /// e.g. 'assets/images/bg_home.png'
  final String asset;
  final Widget child;

  /// 0..1 — higher = more wash over the art (better text contrast).
  final double scrimOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          // Pre-warm the cache so first paint doesn't flash.
          gaplessPlayback: true,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WoodTheme.emeraldDeep.withValues(alpha: 0.28 * scrimOpacity / 0.55),
                WoodTheme.cream.withValues(alpha: 0.42 * scrimOpacity / 0.55),
                WoodTheme.emeraldDeep.withValues(alpha: 0.34 * scrimOpacity / 0.55),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
