import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:passatempo/home_page/home_page.dart';
import 'package:passatempo/widgets/banner_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  TextEditingController _usernameController = TextEditingController();

  InterstitialAd? interstitialService;
  RewardedAd? rewardedService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadIntersttitial();
    loadR();
  }

  Future<void> _saveAndProced(bool isTimed) async {
    String username = _usernameController.text.trim();
    if (username.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userName: username,
          isTimer: isTimed,
        ),
      ),
    );
  }

  void loadIntersttitial() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialService = ad;
            log('load!!!!');
          },
          onAdFailedToLoad: (error) {
            log('Error loading ad');
          },
        ));
  }

  void loadR() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            rewardedService = ad;
            log('load! R!!!');
          },
          onAdFailedToLoad: (error) {
            log('Error loading ad');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 66, 206, 71),
          title: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                WavyAnimatedText(
                  'Passatempo',
                  textStyle: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    fontSize: 24,
                  ),
                  speed: Duration(milliseconds: 200),
                ),
                ColorizeAnimatedText(
                  'Passatempo',
                  textStyle: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    fontSize: 24,
                  ),
                  colors: [
                    Colors.brown,
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue
                  ],
                  speed: Duration(milliseconds: 500),
                )
              ],
              isRepeatingAnimation: true,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            BannerWidget(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your username',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 238, 154, 27),
                ),
                onPressed: () {
                  rewardedService!.show(
                    onUserEarnedReward: (ad, reward) {},
                  );
                  _saveAndProced(true);
                  log('aaaaaaa');
                },
                child: Text(
                  'Play Timed Game',
                  style: TextStyle(fontSize: 18),
                )),
            SizedBox(height: 30),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 238, 154, 27),
                ),
                onPressed: () async {
                  interstitialService!.show();
                  _saveAndProced(false);
                },
                child: Text(
                  'Play Without Timer',
                  style: TextStyle(fontSize: 18),
                )),
          ],
        ));
  }
}
