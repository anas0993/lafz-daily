import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../game/puzzle.dart';
import 'remote_content_service.dart';
import 'storage_service.dart';

/// AdMob wrapper: banner, rewarded (hints), and a once-per-day interstitial.
///
/// Rules enforced here:
/// - No ads at all for Pro users (call [setPro] after purchase/restore).
/// - Interstitial: at most once per calendar day, and only ever shown from
///   the game-finished flow — never mid-game.
/// - Everything degrades gracefully when ads fail to load (offline etc.).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _pro = false;
  bool _initialized = false;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _rewardedReady = false;
  DateTime? _rewardedLoadedAt;

  void setPro(bool value) => _pro = value;
  bool get isPro => _pro;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
      _loadRewarded();
    } catch (e) {
      debugPrint('Ads init failed: $e');
    }
  }

  // ------------------------------------------------------------ banner --
  BannerAd createBanner() {
    // Uses the remote ad unit ID from the admin panel when configured,
    // otherwise the ID from AdsConfig.
    return BannerAd(
      adUnitId: RemoteContentService.instance.effectiveBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, e) {
          debugPrint('Banner failed: $e');
          ad.dispose();
        },
      ),
    )..load();
  }

  // ------------------------------------------------------ interstitial --
  void _loadInterstitial() {
    if (_pro) return;
    InterstitialAd.load(
      adUnitId: RemoteContentService.instance.effectiveInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (e) => debugPrint('Interstitial failed: $e'),
      ),
    );
  }

  /// Shows the interstitial only if: not Pro, not shown today yet.
  /// Returns true if an ad was shown.
  Future<bool> maybeShowInterstitial() async {
    if (_pro) return false;
    // Admin kill-switch from the panel (null = not configured → show).
    if (RemoteContentService.instance.adsEnabled == false) return false;
    final store = StorageService.instance;
    final today = Puzzle.dateKey(DateTime.now());
    if (store.getString('interstitial_day') == today) return false;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        _loadInterstitial();
      },
    );
    await store.setString('interstitial_day', today);
    ad.show();
    return true;
  }

  // ---------------------------------------------------------- rewarded --
  void _loadRewarded() {
    if (_pro) return;
    RewardedAd.load(
      adUnitId: RemoteContentService.instance.effectiveRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
          _rewardedLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (e) {
          debugPrint('Rewarded failed: $e');
          _rewardedReady = false;
        },
      ),
    );
  }

  bool get rewardedReady {
    // Refresh stale ads (older than 1h).
    if (_rewardedLoadedAt != null &&
        DateTime.now().difference(_rewardedLoadedAt!).inHours >= 1) {
      _rewardedReady = false;
      _loadRewarded();
    }
    return _rewardedReady && _rewarded != null;
  }

  /// Shows a rewarded ad; [onRewarded] runs when the user earns the reward.
  /// Returns false when no ad was available.
  Future<bool> showRewarded(void Function() onRewarded) async {
    if (RemoteContentService.instance.adsEnabled == false) return false;
    final ad = _rewarded;
    if (!_rewardedReady || ad == null) {
      _loadRewarded();
      return false;
    }
    _rewardedReady = false;
    _rewarded = null;
    var granted = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        _loadRewarded();
      },
    );
    await ad.show(
        onUserEarnedReward: (AdWithoutView a, RewardItem r) {
      granted = true;
      onRewarded();
    });
    return granted;
  }
}
