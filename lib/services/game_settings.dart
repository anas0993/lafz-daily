import 'storage_service.dart';

/// Gameplay settings: hard mode and color blind mode.
/// Persisted locally, applies across all languages.
class GameSettings {
  GameSettings._();
  static final GameSettings instance = GameSettings._();

  bool get hardMode => StorageService.instance.getBool('hard_mode') ?? false;
  bool get colorBlind => StorageService.instance.getBool('color_blind') ?? false;

  Future<void> setHardMode(bool v) =>
      StorageService.instance.setBool('hard_mode', v);

  Future<void> setColorBlind(bool v) =>
      StorageService.instance.setBool('color_blind', v);
}
