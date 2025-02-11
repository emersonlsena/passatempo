import 'package:flutter/material.dart';
import 'package:passatempo/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextEditingController _usernameController = TextEditingController();
  Future<void> _saveAndProced(bool isTimed) async {
    String username = _usernameController.text.trim();
    if (username.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setBool('isTimed', isTimed);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
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
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your username',
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 238, 154, 27),
                ),
                onPressed: () => _saveAndProced(true),
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
                onPressed: () => _saveAndProced(false),
                child: Text(
                  'Play Without Timer',
                  style: TextStyle(fontSize: 18),
                )),
          ],
        ));
  }
}
