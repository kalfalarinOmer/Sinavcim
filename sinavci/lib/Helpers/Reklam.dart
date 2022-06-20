import 'package:google_mobile_ads/google_mobile_ads.dart';

class Reklam {
  InterstitialAd _interstitialAd;
  int num_of_attempt_load = 0;

  static initialization() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();

    }
  }


  static BannerAd getBannerAd() {
    final BannerAd myBanner = BannerAd(
      adUnitId: 'ca-app-pub-7238047144500317/9020769119',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print("Reklam yülendi");

          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print("Reklam yüklenemedi.");
            ad.dispose();
          },
          onAdOpened: (Ad ad) {
            print("Reklam açıldı");
          }
      ),
    );

    return myBanner;
  }


  void createInterad() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-7238047144500317/5940160262',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            num_of_attempt_load = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            num_of_attempt_load + 1;
            _interstitialAd = null;

            if (num_of_attempt_load <= 2) {
              createInterad();
            }
          }),
    );
  }

  void showInterad() {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(

        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print("ad onAdshowedFullscreen");
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print("ad Disposed");
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad,
            AdError aderror) {
          print('$ad OnAdFailed $aderror');
          ad.dispose();
          createInterad();
        }
    );

    _interstitialAd.show();

    _interstitialAd = null;
  }
}