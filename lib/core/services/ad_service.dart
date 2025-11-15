import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_service.dart';

/// A service to manage mobile ads.
class AdService {
  final SettingsService _settingsService;
  InterstitialAd? _interstitialAd;

  AdService(this._settingsService);

  /// The ad unit ID for the interstitial ad.
  /// This is a test ad unit ID.
  final String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Loads an interstitial ad.
  void loadInterstitialAd() {
    // TEMPORARILY DISABLED FOR TESTING
    return;
    // InterstitialAd.load(
    //   adUnitId: _interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (InterstitialAd ad) {
    //       _interstitialAd = ad;
    //     },
    //     onAdFailedToLoad: (LoadAdError error) {
    //       _interstitialAd = null;
    //     },
    //   ),
    // );
  }

  /// Shows the interstitial ad if it's loaded.
  void showInterstitialAd() {
    if (_settingsService.settings.adsRemoved) {
      return;
    }
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
  RewardedAd? _rewardedAd;

  /// The ad unit ID for the rewarded ad.
  /// This is a test ad unit ID.
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  /// Loads a rewarded ad.
  void loadRewardedAd() {
    // TEMPORARILY DISABLED FOR TESTING
    return;
    // RewardedAd.load(
    //   adUnitId: _rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (RewardedAd ad) {
    //       _rewardedAd = ad;
    //     },
    //     onAdFailedToLoad: (LoadAdError error) {
    //       _rewardedAd = null;
    //     },
    //   ),
    // );
  }

  /// Shows the rewarded ad if it's loaded.
  void showRewardedAd({required Function() onRewarded}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewarded();
        },
      );
      _rewardedAd = null;
    }
  }
}

final adServiceProvider = Provider<AdService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  final adService = AdService(settingsService);
  adService.loadInterstitialAd();
  adService.loadRewardedAd();
  return adService;
});
