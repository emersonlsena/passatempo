import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  BannerAd? smallBanner;
  bool bannerLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBannerAd();
  }

  void loadBannerAd() {
    smallBanner = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/9214589741',
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              bannerLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            log(error.message);
          },
        ));
    smallBanner!.load();
  }

  @override
  Widget build(BuildContext context) {
    return bannerLoaded
        ? SizedBox(
            width: smallBanner!.size.width.toDouble(),
            height: smallBanner!.size.height.toDouble(),
            child: AdWidget(ad: smallBanner!),
          )
        : SizedBox.shrink();
  }
}
