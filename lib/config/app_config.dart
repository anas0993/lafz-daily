import '../l10n/strings.dart';

/// App-wide constants.
class AppConfig {
  static const String appNameEn = 'Word Daily';
  static const String appNameUr = 'لفظ ڈیلی';
  static const String appNameAr = 'لفظ يومي';
  static const String appNameEs = 'Word Diario';
  static const String taglineEn = 'A new word every day';
  static const String taglineUr = 'ہر روز ایک نیا لفظ';
  static const String taglineAr = 'كلمة جديدة كل يوم';
  static const String taglineEs = 'Una palabra nueva cada día';

  /// Display name of the app in the given UI/puzzle language.
  static String appName(AppLang l) => switch (l) {
        AppLang.en => appNameEn,
        AppLang.ur => appNameUr,
        AppLang.ar => appNameAr,
        AppLang.es => appNameEs,
      };

  /// Day 1 of the puzzle calendar. Daily words are derived from the number
  /// of days since this date, so every player worldwide gets the same word.
  static final DateTime epoch = DateTime(2024, 1, 1);

  static const int wordLength = 5;
  static const int maxAttempts = 6;

  /// Free hints granted per day (reset at midnight local time).
  static const int freeHintsPerDay = 1;

  /// Interstitial ad limits.
  static const int maxInterstitialsPerDay = 1;

  /// How many past days are playable in the archive (Pro).
  static const int archiveDays = 60;

  static const String privacyPolicyUrl = 'https://lafzdaily.example.com/privacy';
  static const String termsUrl = 'https://lafzdaily.example.com/terms';

  /// Play Store URL used by the "Rate us" button (updated at release).
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.lafz.dailypuzzle';
}
