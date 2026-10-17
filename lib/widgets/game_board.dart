import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../services/game_settings.dart';
import 'wood_theme.dart';

/// The 6x5 tile board. Tiles flip-reveal after each submitted guess
/// (rotation + subtle scale pop, 60fps-friendly: each tile owns one
/// short-lived controller that is idle except during its own flip).
class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.rows,
    required this.evaluations,
    required this.current,
    required this.lang,
  });

  final List<String> rows;
  final List<List<LetterState>> evaluations;
  final String current;
  final AppLang lang;

  List<String> _lettersOf(String word) => lang.splitLetters(word);

  @override
  Widget build(BuildContext context) {
    final rtl = lang.isRtl;
    final cur = _lettersOf(current);
    final board = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < 6; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 5; c++)
                    _Tile(
                      letter: r < rows.length
                          ? _lettersOf(rows[r])[c]
                          : (r == rows.length && c < cur.length ? cur[c] : ''),
                      state: r < rows.length
                          ? evaluations[r][c]
                          : LetterState.unknown,
                      filled: r < rows.length || c < cur.length,
                      lang: lang,
                      // Stagger the flip left→right for a premium cascade.
                      staggerIndex: c,
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    // Subtle first-run hint over the empty board. GameBoard owns this so
    // game_screen.dart needs no change.
    if (rows.isNotEmpty || current.isNotEmpty) return board;
    return Stack(
      alignment: Alignment.center,
      children: [
        board,
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  S(lang).get('emptyBoardHint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.letter,
    required this.state,
    required this.filled,
    required this.lang,
    required this.staggerIndex,
  });

  final String letter;
  final LetterState state;
  final bool filled;
  final AppLang lang;
  final int staggerIndex;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    duration: const Duration(milliseconds: 420),
    vsync: this,
  );

  /// True once this tile's reveal flip has been triggered. Tiles that are
  /// built already-revealed (archive/resume) skip the animation and just
  /// show the revealed face.
  bool _flipPlayed = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == LetterState.unknown &&
        widget.state != LetterState.unknown &&
        !_flipPlayed) {
      _flipPlayed = true;
      // One tactile pulse per submitted row, on the first tile.
      if (widget.staggerIndex == 0) {
        HapticFeedback.mediumImpact();
      }
      if (widget.staggerIndex > 0) {
        Future.delayed(
          Duration(milliseconds: widget.staggerIndex * 70),
          () {
            if (mounted) _flip.forward(from: 0.0);
          },
        );
      } else {
        _flip.forward(from: 0.0);
      }
    }
  }

  Color _bgFor(LetterState state) {
    final colorBlind = GameSettings.instance.colorBlind;
    return switch (state) {
      // v4.2: core Wordle feedback — correct MUST read as GREEN and
      // present MUST read as YELLOW (matches GameKeyboard mapping).
      LetterState.correct => colorBlind
          ? const Color(0xFFFF6B35) // color-blind: vivid orange
          : WoodTheme.emerald, // rich green
      LetterState.present => colorBlind
          ? const Color(0xFF40C4FF) // color-blind: light blue
          : WoodTheme.gold, // warm golden yellow
      LetterState.absent => const Color(0xFF4E342E), // Dark weathered wood
      LetterState.unknown => widget.filled
          ? const Color(0xFFD7CCC8)
          : const Color(0xFFEFEBE9), // Light natural wood
    };
  }

  Color _fgFor(LetterState state) {
    if (state == LetterState.unknown) {
      return const Color(0xFF3E2723); // Dark wood text on light wood
    }
    // v4.2: dark text on the bright gold (present) tiles, cream on the
    // dark green/brown tiles — matches the keyboard's contrast mapping.
    if (state == LetterState.present) {
      return WoodTheme.bark;
    }
    return const Color(0xFFFFF8E1); // Cream text on dark tiles
  }

  /// 3D-looking wooden tile face: vertical gradient + soft shadow, with a
  /// gold border on correct tiles.
  Widget _face(BuildContext context, LetterState faceState) {
    final base = _bgFor(faceState);
    final isRevealed = faceState != LetterState.unknown;
    final isCorrect = faceState == LetterState.correct;
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WoodTheme.lighten(base, 0.16),
            base,
            WoodTheme.darken(base, 0.22),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: isCorrect
            ? Border.all(color: WoodTheme.gold, width: 2.5)
            : faceState == LetterState.unknown
                ? Border.all(
                    color: WoodTheme.woodLight.withValues(
                        alpha: widget.filled ? 0.7 : 0.25),
                    width: 2,
                  )
                : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isRevealed ? 0.35 : 0.12),
            blurRadius: isRevealed ? 8 : 3,
            offset: Offset(0, isRevealed ? 3 : 1.5),
          ),
          if (isRevealed)
            BoxShadow(
              color: base.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.lang.isLatin ? widget.letter.toUpperCase() : widget.letter,
        style: TextStyle(
          fontSize: widget.lang.isLatin ? 32 : 34,
          fontWeight: FontWeight.w800,
          color: _fgFor(faceState),
          letterSpacing: 0.5,
          shadows: isRevealed
              ? [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        final t = _flip.value;
        // Which face to paint: blank during the first half of the flip,
        // revealed during the second half. Tiles built already-revealed
        // (no flip played) simply show the revealed face, unrotated.
        final faceIsRevealed = widget.state == LetterState.unknown
            ? false
            : (!_flipPlayed || t >= 0.5);
        final angle = _flipPlayed
            ? (faceIsRevealed ? (1.0 - t) * math.pi : t * math.pi)
            : 0.0;
        final scale = _flipPlayed ? 1.0 + 0.07 * math.sin(t * math.pi) : 1.0;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspective for the flip
            ..rotateX(angle)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          alignment: Alignment.center,
          child: _face(
              context, faceIsRevealed ? widget.state : LetterState.unknown),
        );
      },
    );
  }
}
