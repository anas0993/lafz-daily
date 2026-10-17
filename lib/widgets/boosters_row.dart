import 'package:flutter/material.dart';
import 'wood_theme.dart';

/// v4.1 (WS2): wooden booster pills row shown above the game keyboard.
///
/// Three pills — 💡 hint ×N, 🎯 dart ×N, ⏭ skip ×N — each with a count
/// badge. Tapping a pill calls its callback; a pill with count 0 renders
/// dimmed but still tappable (the owner decides what an empty tap does).
class BoostersRow extends StatelessWidget {
  const BoostersRow({
    super.key,
    required this.hints,
    required this.darts,
    required this.skips,
    required this.onHint,
    required this.onDart,
    required this.onSkip,
  });

  final int hints;
  final int darts;
  final int skips;
  final VoidCallback onHint;
  final VoidCallback onDart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _BoosterPill(
              emoji: '💡',
              count: hints,
              onTap: onHint,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BoosterPill(
              emoji: '🎯',
              count: darts,
              onTap: onDart,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BoosterPill(
              emoji: '⏭',
              count: skips,
              onTap: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

/// One wooden booster pill: emoji + count badge on a wood gradient.
class _BoosterPill extends StatelessWidget {
  const _BoosterPill({
    required this.emoji,
    required this.count,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAny = count > 0;
    return Opacity(
      opacity: hasAny ? 1.0 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WoodTheme.lighten(WoodTheme.wood, 0.08),
                WoodTheme.wood,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: WoodTheme.gold.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WoodTheme.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: WoodTheme.gold.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  '×$count',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: WoodTheme.woodDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
