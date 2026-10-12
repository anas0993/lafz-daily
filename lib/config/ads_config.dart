/// AdMob configuration.
///
/// The app ships with Google's official TEST ad unit IDs so ads never serve
/// real impressions during development. Before release, replace the
/// [_kReal...] placeholders below with the real IDs from the AdMob console
/// and flip [useTestAds] to false.
class AdsConfig {
  /// Set to false for the production release (with real IDs filled in).
  static const bool useTestAds = true;

  // ------------------------------------------------------------------
  // Google's official test IDs (safe to ship in debug builds).
  // ------------------------------------------------------------------
  static const String _testAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // ------------------------------------------------------------------
  // TODO(RELEASE): paste the real AdMob IDs here.
  // ------------------------------------------------------------------
  static const String _realAppIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
  static const String _realBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _realInterstitialId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _realRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  static String get appIdAndroid =>
      useTestAds ? _testAppIdAndroid : _realAppIdAndroid;
  static String get bannerId => useTestAds ? _testBannerId : _realBannerId;
  static String get interstitialId =>
      useTestAds ? _testInterstitialId : _realInterstitialId;
  static String get rewardedId =>
      useTestAds ? _testRewardedId : _realRewardedId;
}
