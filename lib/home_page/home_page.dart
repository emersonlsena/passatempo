import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passatempo/models/triva_question_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TrivaQuestionModel> questions = [];
  int current = 0;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool isFront = true;
  int score = 0;

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  final dio = Dio();

  void getHttp() async {
    try {
      final response =
          await dio.get('https://the-trivia-api.com/v2/questions/');
      setState(() {
        questions = (response.data as List)
            .map((item) => TrivaQuestionModel.fromJson(item))
            .toList();
      });
    } catch (e) {
      log('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas')),
      );
    }
  }

  // Function to show game over dialog
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over! 🎉", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: $score/${questions.length}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Icon(Icons.emoji_events,
                  color: const Color.fromARGB(255, 182, 140, 14), size: 50),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text('Play Again', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text('Exit', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // Function to restart the game
  void restartGame() {
    setState(() {
      current = 0;
      score = 0;
      questions = []; // Clear existing questions
    });

    getHttp(); // Fetch new questions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
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
                Colors.blue,
              ],
              speed: Duration(milliseconds: 500),
            )
          ],
          isRepeatingAnimation: true,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Color.fromARGB(255, 104, 138, 198),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'User',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Score',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  '$score',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Pergunta ${current + 1}/${questions.length}',
              style: GoogleFonts.workSans(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 46, 114, 48),
              ),
            ),
            questions.isEmpty
                ? CircularProgressIndicator()
                : FlipCard(
                    key: cardKey,
                    onFlip: () {
                      setState(() {
                        isFront = false;
                      });
                    },
                    front: TriviaCard(
                      isFront: true,
                      filho: Center(
                        child: Text(
                          questions[current].question,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    back: TriviaCard(
                      isFront: false,
                      filho: Column(
                        children: questions[current]
                            .options
                            .map((resposta) => ListTile(
                                  title: Text(
                                    resposta,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    bool isCorrect = resposta ==
                                        questions[current].correctAnswer;

                                    if (isCorrect) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('Resposta correta!'),
                                      ));
                                      score++;
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          'Resposta Errada! Correta seria: ${questions[current].correctAnswer}',
                                        ),
                                      ));
                                    }

                                    if (current >= questions.length - 1) {
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        showGameOverDialog();
                                      });
                                    } else {
                                      setState(() {
                                        current++;
                                        cardKey.currentState!.toggleCard();
                                      });
                                    }
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TriviaCard extends StatelessWidget {
  final Widget filho;
  final bool isFront;
  const TriviaCard({
    required this.filho,
    required this.isFront,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(10),
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(10, 20),
          )
        ],
        color: isFront ? Colors.brown : Colors.blueGrey,
        borderRadius: BorderRadius.circular(40),
      ),
      child: filho,
    );
  }
}
