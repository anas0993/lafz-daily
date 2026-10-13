import 'package:flutter/material.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../services/game_settings.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final colorBlind = GameSettings.instance.colorBlind;
    return switch (st) {
      LetterState.correct =>
        colorBlind ? const Color(0xFFFF6B35) : const Color(0xFF00C853),
      LetterState.present =>
        colorBlind ? const Color(0xFF40C4FF) : const Color(0xFFFFD600),
      LetterState.absent => const Color(0xFF616161),
      LetterState.unknown => scheme.surfaceContainerHighest,
    };
  }

  Color _keyFg(BuildContext context, String key) {
    final st =
        keyStates[lang.normalizeWord(key)] ?? LetterState.unknown;
    return st == LetterState.unknown
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;
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
    final isRevealed = color != Theme.of(context).colorScheme.surfaceContainerHighest;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isRevealed
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
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
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface)),
        ),
      ),
    );
  }
}
