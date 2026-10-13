import 'package:flutter/foundation.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import 'storage_service.dart';

/// Per-language statistics, persisted locally as JSON.
///
/// Streaks only count daily puzzles. Practice games count toward
/// played/wins but never affect the streak.
class Stats {
  int played = 0;
  int wins = 0;
  int currentStreak = 0;
  int maxStreak = 0;
  List<int> distribution = List.filled(6, 0); // wins by guess count 1..6
  String lastPlayedDate = ''; // dateKey of last daily game
  String lastWinDate = ''; // dateKey of last daily WIN (drives the streak)

  Stats();

  Stats.fromJson(Map<String, dynamic> j) {
    played = (j['played'] as num?)?.toInt() ?? 0;
    wins = (j['wins'] as num?)?.toInt() ?? 0;
    currentStreak = (j['currentStreak'] as num?)?.toInt() ?? 0;
    maxStreak = (j['maxStreak'] as num?)?.toInt() ?? 0;
    final d = j['distribution'] as List?;
    if (d != null && d.length == 6) {
      distribution = d.map((e) => (e as num).toInt()).toList();
    }
    lastPlayedDate = (j['lastPlayedDate'] as String?) ?? '';
    lastWinDate = (j['lastWinDate'] as String?) ?? '';
  }

  Map<String, dynamic> toJson() => {
        'played': played,
        'wins': wins,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'distribution': distribution,
        'lastPlayedDate': lastPlayedDate,
        'lastWinDate': lastWinDate,
      };

  double get winPct => played == 0 ? 0 : wins / played * 100;
}

class StatsService extends ChangeNotifier {
  StatsService._();
  static final StatsService instance = StatsService._();

  final _cache = <AppLang, Stats>{};

  String _key(AppLang lang) => 'stats_${lang.name}';

  Stats get(AppLang lang) {
    return _cache.putIfAbsent(lang, () {
      final j = StorageService.instance.getJson(_key(lang));
      return j == null ? Stats() : Stats.fromJson(j);
    });
  }

  Future<void> _save(AppLang lang) =>
      StorageService.instance.setJson(_key(lang), get(lang).toJson());

  /// Records a finished game.
  /// [isDaily]: daily puzzles count toward played/wins; only *today's*
  /// puzzle affects the streak (archive replays don't).
  /// [dateKey]: the puzzle's calendar date key.
  Future<void> recordGame({
    required AppLang lang,
    required bool won,
    required int guesses, // 1..6, meaningful when won
    required bool isDaily,
    String? dateKey,
  }) async {
    final s = get(lang);
    s.played++;
    if (won) {
      s.wins++;
      if (guesses >= 1 && guesses <= 6) s.distribution[guesses - 1]++;
    }
    if (isDaily && dateKey != null) {
      final todayKey = Puzzle.dateKey(DateTime.now());
      if (dateKey == todayKey) {
        // Streak = consecutive days with at least one daily WIN. With five
        // puzzles a day, a single loss must not wipe the streak — only a
        // winless day breaks it (detected on the next win).
        if (won) {
          final yesterdayKey = Puzzle.dateKey(
              DateTime.now().subtract(const Duration(days: 1)));
          if (s.lastWinDate == yesterdayKey || s.lastWinDate.isEmpty) {
            s.currentStreak += 1;
          } else if (s.lastWinDate != todayKey) {
            s.currentStreak = 1;
          }
          if (s.currentStreak > s.maxStreak) s.maxStreak = s.currentStreak;
          s.lastWinDate = todayKey;
        }
        s.lastPlayedDate = todayKey;
      }
      // Archive dates: played/wins counted above, streak untouched.
    }
    await _save(lang);
    // Safe async notification (prevents freeze during build)
    Future.microtask(() {
      try { notifyListeners(); } catch (_) {}
    });
  }
}
