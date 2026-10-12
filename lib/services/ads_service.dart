import 'package:flutter/material.dart';

/// Stub: ads disabled in the clean build. Same public API, no plugin.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _pro = false;
  void setPro(bool value) => _pro = value;
  bool get isPro => _pro;

  Future<void> init() async {}

  /// Returns an empty box instead of a banner.
  Widget createBanner() => const SizedBox.shrink();

  Future<bool> maybeShowInterstitial() async => false;
  bool get rewardedReady => false;
  Future<bool> showRewarded(void Function() onRewarded) async => false;
}
