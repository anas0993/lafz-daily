import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/storage_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';
import 'home_screen.dart';

/// First-launch tutorial + reference. Shows 3 example rows with
/// explanations. Original examples (not copied from any other game).
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key, required this.firstLaunch});
  final bool firstLaunch;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final rtl = appState.lang.isRtl;
    final latin = appState.lang.isLatin;
    final scheme = Theme.of(context).colorScheme;

    Widget exampleRow(
        List<String> letters, List<LetterState> states, String caption) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 5; i++)
                  Container(
                    width: 44,
                    height: 44,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    decoration: BoxDecoration(
                      color: switch (states[i]) {
                        // Wooden tiles: match the v4.0 game board —
                        // dark wood for correct, medium wood for present.
                        LetterState.correct => WoodTheme.wood,
                        LetterState.present => WoodTheme.woodLight,
                        _ => scheme.surfaceContainerHighest,
                      },
                      border: Border.all(
                          color: states[i] == LetterState.unknown
                              ? scheme.outline
                              : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      latin ? letters[i].toUpperCase() : letters[i],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: states[i] == LetterState.unknown
                            ? scheme.onSurface
                            : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(caption, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
        ],
      );
    }

    // Original examples per language (shown below).

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('howToPlay')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.get('how1t'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(s.get('how1b'), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 14),
            Text(s.get('how2t'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(s.get('how2b'), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            if (appState.lang == AppLang.en) ...[
              exampleRow(
                  ['w', 'o', 'r', 'd', 's'],
                  [
                    LetterState.correct,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'W is in the word and in the right place.'),
              exampleRow(
                  ['l', 'i', 'g', 'h', 't'],
                  [
                    LetterState.unknown,
                    LetterState.present,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'I is in the word but in the wrong place.'),
              exampleRow(
                  ['q', 'u', 'i', 'c', 'k'],
                  List.filled(5, LetterState.absent),
                  'None of these letters are in the word.'),
            ] else if (appState.lang == AppLang.es) ...[
              exampleRow(
                  ['m', 'u', 'n', 'd', 'o'],
                  [
                    LetterState.correct,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'M está en la palabra y en el lugar correcto.'),
              exampleRow(
                  ['c', 'a', 'r', 't', 'a'],
                  [
                    LetterState.unknown,
                    LetterState.present,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'A está en la palabra pero en otro lugar.'),
              exampleRow(
                  ['c', 'i', 'n', 'c', 'o'],
                  List.filled(5, LetterState.absent),
                  'Ninguna de estas letras está en la palabra.'),
            ] else if (appState.lang == AppLang.ar) ...[
              exampleRow(
                  ['م', 'ك', 'ت', 'ب', 'ه'],
                  [
                    LetterState.correct,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'حرف «م» في الكلمة وفي مكانه الصحيح.'),
              exampleRow(
                  ['ح', 'د', 'ي', 'ق', 'ه'],
                  [
                    LetterState.unknown,
                    LetterState.present,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  'حرف «د» في الكلمة لكن في مكان خاطئ.'),
              exampleRow(
                  ['ز', 'خ', 'ف', 'ث', 'ظ'],
                  List.filled(5, LetterState.absent),
                  'لا يوجد أيٌّ من هذه الحروف في الكلمة.'),
            ] else ...[
              exampleRow(
                  ['س', 'ل', 'ا', 'م', 'ت'],
                  [
                    LetterState.correct,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  '’س‘ لفظ میں ہے اور صحیح جگہ پر ہے۔'),
              exampleRow(
                  ['م', 'ح', 'ب', 'ت', 'ا'],
                  [
                    LetterState.unknown,
                    LetterState.present,
                    LetterState.unknown,
                    LetterState.unknown,
                    LetterState.unknown
                  ],
                  '’ح‘ لفظ میں ہے مگر غلط جگہ پر ہے۔'),
              exampleRow(
                  ['ق', 'ل', 'م', 'د', 'ن'],
                  List.filled(5, LetterState.absent),
                  'ان میں سے کوئی حرف لفظ میں نہیں۔'),
            ],
            const SizedBox(height: 6),
            Text(s.get('how3t'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(s.get('how3b'), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 14),
            Text(s.get('earnT'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(s.get('earnB'), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await StorageService.instance
                      .setBool('howto_seen', true);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(s.get('ok'), style: const TextStyle(fontSize: 17)),
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
