import '../config/ads_config.dart';
import '../config/app_config.dart';
import '../l10n/strings.dart';

/// Remote content from the Firebase admin panel (see admin/README.md).
///
/// Firebase remote content is TEMPORARILY DISABLED: the Firebase
/// integration crashed the app on launch when no Firebase project was
/// configured (no google-services.json).
///
/// This stub keeps the exact same public API so every call site works
/// unchanged — the app simply uses its bundled word lists and hardcoded
/// defaults until Firebase is properly wired up.
///
/// TO RE-ENABLE later:
///   1. Restore the real implementation from
///      `lib/services/remote_content_service.dart.firebasebak`.
///   2. Re-add the Firebase packages to pubspec.yaml.
///   3. Add the project's `google-services.json` under android/app/.
///   4. `flutter pub get` and rebuild.
class RemoteContentService {
  RemoteContentService._();
  static final RemoteContentService instance = RemoteContentService._();

  /// Firebase is disabled: there is no remote content, so never "ready".
  bool get ready => false;

  /// No-op: returns immediately. Bundled content stays active.
  Future<void> init() async {}

  // ------------------------------------------------------- word lists --
  /// Always null → callers keep the bundled answer list.
  List<String>? remoteAnswers(AppLang lang) => null;

  /// Always null → callers keep the bundled guess list.
  List<String>? remoteGuesses(AppLang lang) => null;

  // ------------------------------------------------------------- ads --
  /// Explicit kill-switch from the admin panel (null = not configured).
  bool? get adsEnabled => null;

  String get effectiveBannerId => AdsConfig.bannerId;

  String get effectiveInterstitialId => AdsConfig.interstitialId;

  String get effectiveRewardedId => AdsConfig.rewardedId;

  int get effectiveMaxInterstitialsPerDay => AppConfig.maxInterstitialsPerDay;

  // -------------------------------------------------------- settings --
  int get effectiveFreeHintsPerDay => AppConfig.freeHintsPerDay;

  int get effectiveArchiveDays => AppConfig.archiveDays;
}
