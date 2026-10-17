import 'dart:math';

import 'coins_service.dart';
import 'storage_service.dart';

/// WS5 (v4.1): usable boosters — Darts and Skips (plus a small bonus Hints
/// inventory) — bought with virtual game coins. Coins are NOT cash, NOT
/// redeemable, and carry no monetary value.
///
/// Starter pack: every new user begins with 2 hints, 3 darts and 3 skips
/// so the feature is discoverable without spending anything.
class BoosterService {
  BoosterService._();
  static final BoosterService instance = BoosterService._();

  static const _kHints = 'wd_booster_hints';
  static const _kDarts = 'wd_booster_darts';
  static const _kSkips = 'wd_booster_skips';
  static const _kSeeded = 'wd_booster_seeded';

  /// Coins charged for one Dart.
  int get dartCost => 15;

  /// Coins charged for one Skip.
  int get skipCost => 10;

  final _rng = Random();

  int? _hints;
  int? _darts;
  int? _skips;

  /// Loads counts from SharedPreferences. Lazy-safe: also runs
  /// automatically on first read. Never throws.
  Future<void> init() async {
    await StorageService.instance.init();
    _load();
  }

  void _load() {
    if (_hints != null) return;
    try {
      if (!(StorageService.instance.getBool(_kSeeded) ?? false)) {
        _hints = 2;
        _darts = 3;
        _skips = 3;
        StorageService.instance.setBool(_kSeeded, true);
        _save();
        return;
      }
      _hints = StorageService.instance.getInt(_kHints) ?? 0;
      _darts = StorageService.instance.getInt(_kDarts) ?? 0;
      _skips = StorageService.instance.getInt(_kSkips) ?? 0;
    } catch (_) {
      _hints = 0;
      _darts = 0;
      _skips = 0;
    }
  }

  Future<void> _save() async {
    try {
      await Future.wait([
        StorageService.instance.setInt(_kHints, hintCount),
        StorageService.instance.setInt(_kDarts, dartCount),
        StorageService.instance.setInt(_kSkips, skipCount),
      ]);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  int get hintCount {
    _load();
    return _hints!;
  }

  int get dartCount {
    _load();
    return _darts!;
  }

  int get skipCount {
    _load();
    return _skips!;
  }

  /// Buys one Dart for [dartCost] coins. Returns false when the coin
  /// balance is insufficient (nothing is spent, no dart granted).
  Future<bool> buyDart() async {
    _load();
    final ok = await CoinsService.instance.spendCoins(dartCost);
    if (!ok) return false;
    _darts = dartCount + 1;
    await _save();
    return true;
  }

  /// Buys one Skip for [skipCost] coins. Returns false when the coin
  /// balance is insufficient.
  Future<bool> buySkip() async {
    _load();
    final ok = await CoinsService.instance.spendCoins(skipCost);
    if (!ok) return false;
    _skips = skipCount + 1;
    await _save();
    return true;
  }

  /// Consumes one hint from the inventory (no-op when empty).
  void useHint() {
    if (hintCount <= 0) return;
    _hints = hintCount - 1;
    _save();
  }

  /// Consumes one dart from the inventory (no-op when empty).
  void useDart() {
    if (dartCount <= 0) return;
    _darts = dartCount - 1;
    _save();
  }

  /// Consumes one skip from the inventory (no-op when empty).
  void useSkip() {
    if (skipCount <= 0) return;
    _skips = skipCount - 1;
    _save();
  }

  /// Grants [n] darts (rewards, achievements, admin). No-op when n <= 0.
  void addDarts(int n) {
    if (n <= 0) return;
    _load();
    _darts = dartCount + n;
    _save();
  }

  /// Grants [n] skips. No-op when n <= 0.
  void addSkips(int n) {
    if (n <= 0) return;
    _load();
    _skips = skipCount + n;
    _save();
  }

  /// Grants [n] hints. No-op when n <= 0.
  void addHints(int n) {
    if (n <= 0) return;
    _load();
    _hints = hintCount + n;
    _save();
  }

  /// Picks up to 3 "dart" letters from [alphabet] — letters that are
  /// guaranteed absent: not in [answer] and not already marked absent.
  /// The calling game screen greys these out on the keyboard.
  List<String> dartTargets({
    required String answer,
    required Set<String> alreadyMarkedAbsent,
    required List<String> alphabet,
  }) {
    final answerSet =
        answer.runes.map((c) => String.fromCharCode(c)).toSet();
    final pool = alphabet
        .where((l) => !answerSet.contains(l) && !alreadyMarkedAbsent.contains(l))
        .toList();
    pool.shuffle(_rng);
    return pool.take(3).toList();
  }
}
