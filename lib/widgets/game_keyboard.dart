import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../services/game_settings.dart';
import 'wood_theme.dart';

/// On-screen keyboard with per-letter color states.
/// Latin languages: QWERTY. Urdu/Arabic: 4-row layouts covering every
/// letter in the bundled word lists (derived from the lists' character set).
class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    super.key,
    required this.lang,
    required this.keyStates,
    required this.onKey,
    required this.onEnter,
    required this.onBackspace,
    required this.s,
  });

  final AppLang lang;
  final Map<String, LetterState> keyStates;
  final void Function(String) onKey;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final S s;

  static const _latinRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  // Covers all 42 distinct letters used in the Urdu word lists.
  static const _urRows = [
    ['ا', 'ب', 'پ', 'ت', 'ٹ', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ڈ', 'ذ', 'ر'],
    ['ڑ', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ک'],
    ['گ', 'ل', 'م', 'ن', 'ں', 'و', 'ہ', 'ھ', 'ء', 'ی', 'ے'],
    ['آ', 'ئ', 'ؤ'],
  ];

  // Covers all 29 distinct letters used in the Arabic word lists
  // (derived from the lists' character set):
  // ء ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ط ظ ع غ ف ق ك ل م ن ه و ي
  static const _arRows = [
    ['ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش'],
    ['ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و'],
    ['ي', 'ء'],
  ];

  Color _keyColor(BuildContext context, String key) {
    final st = keyStates[lang.normalizeWord(key)] ?? LetterState.unknown;
    final colorBlind = GameSettings.instance.colorBlind;
    // Cream/wood tones: unpressed keys are cream, correct is emerald,
    // present is gold, absent is a warm brown-grey.
    return switch (st) {
      LetterState.correct =>
        colorBlind ? const Color(0xFFFF6B35) : WoodTheme.emerald,
      LetterState.present =>
        colorBlind ? const Color(0xFF40C4FF) : WoodTheme.gold,
      LetterState.absent => const Color(0xFF6D4C41),
      LetterState.unknown => WoodTheme.cream,
    };
  }

  Color _keyFg(BuildContext context, String key) {
    final st = keyStates[lang.normalizeWord(key)] ?? LetterState.unknown;
    // Dark wood text on the light (cream/gold) keys, white on dark keys.
    final darkText =
        st == LetterState.unknown || st == LetterState.present;
    return darkText ? WoodTheme.bark : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final rows = switch (lang) {
      AppLang.en || AppLang.es => _latinRows,
      AppLang.ur => _urRows,
      AppLang.ar => _arRows,
    };
    final latin = lang.isLatin;
    return Directionality(
      textDirection: lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (i == rows.length - 1) ...[
                    _WideKey(
                        label: s.get('enter'),
                        onTap: onEnter,
                        flex: latin ? 15 : 20),
                    const SizedBox(width: 4),
                  ],
                  for (final k in rows[i]) ...[
                    _Key(
                      label: latin ? k.toUpperCase() : k,
                      color: _keyColor(context, k),
                      fg: _keyFg(context, k),
                      onTap: () => onKey(k),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (i == rows.length - 1)
                    _WideKey(
                        label: '⌫',
                        onTap: onBackspace,
                        flex: latin ? 15 : 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared press feedback for every keyboard tap: light haptic + click.
void _keyPressFeedback() {
  HapticFeedback.lightImpact();
  SystemSound.play(SystemSoundType.click);
}

class _Key extends StatelessWidget {
  const _Key(
      {required this.label,
      required this.color,
      required this.fg,
      required this.onTap});
  final String label;
  final Color color;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRevealed = color != WoodTheme.cream;
    return Expanded(
      child: InkWell(
        onTap: () {
          _keyPressFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Subtle 3D wooden-key gradient.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WoodTheme.lighten(color, 0.12),
                color,
                WoodTheme.darken(color, 0.14),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: WoodTheme.woodLight.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isRevealed ? 0.25 : 0.12),
                blurRadius: isRevealed ? 5 : 3,
                offset: Offset(0, isRevealed ? 2.5 : 1.5),
              ),
            ],
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.3)),
        ),
      ),
    );
  }
}

class _WideKey extends StatelessWidget {
  const _WideKey(
      {required this.label, required this.onTap, required this.flex});
  final String label;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          _keyPressFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WoodTheme.lighten(WoodTheme.creamDeep, 0.1),
                WoodTheme.creamDeep,
                WoodTheme.darken(WoodTheme.creamDeep, 0.12),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: WoodTheme.woodLight.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: WoodTheme.bark)),
        ),
      ),
    );
  }
}
