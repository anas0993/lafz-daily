import 'package:flutter/foundation.dart';
import 'coins_service.dart';
import 'storage_service.dart';

/// Static definition of one achievement (id, text keys, coin reward).
class AchievementDef {
  final String id;
  final String titleKey;
  final String descKey;
  final int coins;

  const AchievementDef(this.id, this.titleKey, this.descKey, this.coins);
}

/// An achievement definition plus its current locked/unlocked state.
class AchievementState {
  final AchievementDef def;
  final bool unlocked;

  const AchievementState(this.def, this.unlocked);
}

/// Local achievements. Unlocked ids are stored in shared_preferences as
/// 'wd_achievements'. All unlock methods are idempotent — each achievement is
/// granted (and its coins paid) exactly once, no matter how often the caller
/// invokes them.
///
/// PARENT WIRING:
///   - On every puzzle WIN:
///       `final totalWins = StatsService.instance.get(lang).wins;`
///       `final newOnes = await AchievementsService.instance.unlockWinRelated(`
///           `totalWins: totalWins, guesses: guessesUsed);`
///     Show an "achievement unlocked" dialog for each id in newOnes.
///   - After `recordPlayDay()` (once per puzzle completion):
///       `await AchievementsService.instance.checkStreakUnlocks(`
///           `RewardsService.instance.playStreak);`
///   - On every SCRAMBLE win (parent tracks total scramble wins, e.g. in
///     shared_preferences as 'wd_scramble_wins'):
///       `await AchievementsService.instance.checkScrambleUnlocks(total);`
///   - Generic: `await AchievementsService.instance.checkAndUnlock('some_id');`
class AchievementsService extends ChangeNotifier {
  AchievementsService._();
  static final AchievementsService instance = AchievementsService._();

  static const _key = 'wd_achievements';

  static const defs = <AchievementDef>[
    AchievementDef('first_win', 'achFirstWin', 'achFirstWinDesc', 10),
    AchievementDef('rookie', 'achRookie', 'achRookieDesc', 25),
    AchievementDef('pro', 'achPro', 'achProDesc', 60),
    AchievementDef('master', 'achMaster', 'achMasterDesc', 150),
    AchievementDef('sharp_shooter', 'achSharp', 'achSharpDesc', 40),
    AchievementDef('week_warrior', 'achWeekWarrior', 'achWeekWarriorDesc', 50),
    AchievementDef('month_legend', 'achMonthLegend', 'achMonthLegendDesc', 200),
    AchievementDef(
        'scramble_master', 'achScramble', 'achScrambleDesc', 60),
  ];

  Set<String>? _unlocked;

  Set<String> get _ids {
    if (_unlocked == null) {
      final raw = StorageService.instance.getJson(_key);
      final list = raw == null ? null : raw['ids'] as List?;
      _unlocked = (list ?? [])
          .map((e) => e.toString())
          .where((id) => defs.any((d) => d.id == id))
          .toSet();
    }
    return _unlocked!;
  }

  Future<void> _save() => StorageService.instance
      .setJson(_key, {'ids': _ids.toList()});

  void _notify() {
    Future.microtask(() {
      try {
        notifyListeners();
      } catch (_) {}
    });
  }

  /// Unlocks [id] if not already unlocked. Returns true only when the unlock
  /// is new (coins are granted exactly once). Throws [ArgumentError] for an
  /// unknown id.
  Future<bool> checkAndUnlock(String id) async {
    if (_ids.contains(id)) return false;
    final def = defs.firstWhere((d) => d.id == id,
        orElse: () => throw ArgumentError('Unknown achievement: $id'));
    _ids.add(id);
    await _save();
    await CoinsService.instance.addCoins(def.coins, reason: 'achievement:$id');
    _notify();
    return true;
  }

  /// Evaluates every win-related achievement after a puzzle win.
  /// [totalWins] = all-time wins (across languages), [guesses] = attempts the
  /// winning game took (1..6). Returns the newly unlocked definitions so the
  /// caller can celebrate them. Safe to call repeatedly.
  Future<List<AchievementDef>> unlockWinRelated({
    required int totalWins,
    required int guesses,
  }) async {
    final newly = <AchievementDef>[];
    final checks = <String>[
      if (totalWins >= 1) 'first_win',
      if (totalWins >= 10) 'rookie',
      if (totalWins >= 50) 'pro',
      if (totalWins >= 100) 'master',
      if (guesses <= 2) 'sharp_shooter',
    ];
    for (final id in checks) {
      if (await checkAndUnlock(id)) {
        newly.add(defs.firstWhere((d) => d.id == id));
      }
    }
    return newly;
  }

  /// Evaluates play-streak achievements. Call after recordPlayDay() with the
  /// current consecutive play-day streak. Returns newly unlocked definitions.
  Future<List<AchievementDef>> checkStreakUnlocks(int playStreak) async {
    final newly = <AchievementDef>[];
    if (playStreak >= 7 && await checkAndUnlock('week_warrior')) {
      newly.add(defs.firstWhere((d) => d.id == 'week_warrior'));
    }
    if (playStreak >= 30 && await checkAndUnlock('month_legend')) {
      newly.add(defs.firstWhere((d) => d.id == 'month_legend'));
    }
    return newly;
  }

  /// Evaluates the scramble achievement. [totalScrambleWins] = all-time
  /// scramble wins. Returns newly unlocked definitions.
  Future<List<AchievementDef>> checkScrambleUnlocks(
      int totalScrambleWins) async {
    final newly = <AchievementDef>[];
    if (totalScrambleWins >= 10 &&
        await checkAndUnlock('scramble_master')) {
      newly.add(defs.firstWhere((d) => d.id == 'scramble_master'));
    }
    return newly;
  }

  /// All achievements with their current locked/unlocked state, in display
  /// order.
  List<AchievementState> all() =>
      defs.map((d) => AchievementState(d, _ids.contains(d.id))).toList();

  bool isUnlocked(String id) => _ids.contains(id);

  /// Number of unlocked achievements (handy for progress display).
  int get unlockedCount => _ids.length;
}
