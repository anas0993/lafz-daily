// Game-logic tests for the 4-language word puzzle (no widgets).
// Run with: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:lafz_daily/data/word_repository.dart';
import 'package:lafz_daily/game/arabic_text.dart';
import 'package:lafz_daily/game/evaluator.dart';
import 'package:lafz_daily/game/lang_utils.dart';
import 'package:lafz_daily/l10n/strings.dart';

void main() {
  group('language behavior', () {
    test('RTL / Latin flags', () {
      expect(AppLang.ur.isRtl && AppLang.ar.isRtl, isTrue);
      expect(AppLang.en.isRtl || AppLang.es.isRtl, isFalse);
      expect(AppLang.en.isLatin && AppLang.es.isLatin, isTrue);
      expect(AppLang.ur.isLatin || AppLang.ar.isLatin, isFalse);
    });

    test('normalization', () {
      expect(AppLang.en.normalizeWord('WoRdS'), 'words');
      expect(AppLang.es.normalizeWord('MuNdO'), 'mundo');
      expect(AppLang.ur.normalizeWord('كتاب'), 'کتاب');
      expect(normalizeArabic('مَكْتَبَة'), 'مكتبه');
      expect(normalizeArabic('أإآئؤ'), 'ااايو');
    });

    test('splitting', () {
      expect(AppLang.ar.splitLetters('مكتبه').length, 5);
      expect(AppLang.es.splitLetters('mundo').join(), 'mundo');
      expect(AppLang.en.splitLetters('Words').join(), 'words');
    });

    test('appLangFromCode', () {
      expect(appLangFromCode('ar'), AppLang.ar);
      expect(appLangFromCode('es'), AppLang.es);
      expect(appLangFromCode('ur'), AppLang.ur);
      expect(appLangFromCode('bogus'), AppLang.en);
    });
  });

  group('word repositories', () {
    for (final lang in AppLang.values) {
      test('${lang.name} lists are valid', () {
        final repo = WordRepository(lang);
        expect(repo.answers, isNotEmpty);
        expect(repo.validGuesses.length,
            greaterThanOrEqualTo(repo.answers.length));
        final a = repo.answers.first;
        expect(lang.splitLetters(a).length, 5);
        expect(repo.isValidGuess(a), isTrue);
        expect(repo.isValidGuess('xxxxx'), isFalse);
        final daily = repo.dailyAnswer(DateTime(2026, 10, 11));
        expect(lang.splitLetters(daily).length, 5);
        expect(
            evaluateGuess(repo.answerLetters(a), repo.answerLetters(a))
                .every((s) => s == LetterState.correct),
            isTrue);
      });
    }
  });

  group('strings', () {
    for (final lang in AppLang.values) {
      test('${lang.name} translations present', () {
        final s = S(lang);
        expect(s.get('playDaily'), isNotEmpty);
        expect(s.get('enter'), isNotEmpty);
        expect(s.puzzleTag(123), contains('#123'));
      });
    }

    test('puzzleTag exact strings', () {
      expect(S(AppLang.ar).puzzleTag(7), 'لفظ يومي #7');
      expect(S(AppLang.es).puzzleTag(7), 'Lafz Diario #7');
      expect(S(AppLang.en).puzzleTag(7), 'Lafz Daily #7');
      expect(S(AppLang.ur).puzzleTag(7), 'لفظ ڈیلی #7');
    });
  });
}
