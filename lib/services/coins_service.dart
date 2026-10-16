import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Virtual game coins. These are NOT cash, NOT redeemable, and carry no
/// monetary value — they are purely an in-app game currency used to keep
/// players engaged (daily rewards, achievements, milestones).
///
/// PARENT WIRING (coin award hooks — call these from the game flow):
///   - Puzzle win:        `await CoinsService.instance.addCoins(10, reason: 'puzzle_win');`
///   - Scramble win:      `await CoinsService.instance.addCoins(15, reason: 'scramble_win');`
/// RewardsService and AchievementsService credit coins through this service
/// automatically for daily logins, milestones and achievements.
class CoinsService extends ChangeNotifier {
  CoinsService._();
  static final CoinsService instance = CoinsService._();

  static const _key = 'wd_coins';

  int? _balance;

  /// Current balance, loaded lazily from shared_preferences.
  int get balance {
    _balance ??= StorageService.instance.getInt(_key) ?? 0;
    return _balance!;
  }

  Future<int> getBalance() async => balance;

  Future<void> _save() =>
      StorageService.instance.setInt(_key, balance);

  void _notify() {
    // Safe async notification (prevents freeze during build).
    Future.microtask(() {
      try {
        notifyListeners();
      } catch (_) {}
    });
  }

  /// Adds [n] virtual coins. No-op when [n] <= 0.
  Future<void> addCoins(int n, {String reason = ''}) async {
    if (n <= 0) return;
    _balance = balance + n;
    await _save();
    _notify();
  }

  /// Attempts to spend [n] coins. Returns false when the balance is
  /// insufficient (nothing is deducted). No-op/true when [n] <= 0.
  Future<bool> spendCoins(int n) async {
    if (n <= 0) return true;
    if (balance < n) return false;
    _balance = balance - n;
    await _save();
    _notify();
    return true;
  }
}
