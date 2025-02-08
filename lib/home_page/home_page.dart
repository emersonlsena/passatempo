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
  double count = 15.0;
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  void getHttp() async {
    try {
      final response =
          await dio.get('https://the-trivia-api.com/v2/questions/');
      setState(() {
        questions = (response.data as List)
            .map((item) => TrivaQuestionModel.fromJson(item))
            .toList();
      });
      startTimer();
    } catch (e) {
      log('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas')),
      );
    }
  }

  void startTimer() {
    count = 15.0;
    Future.doWhile(() async {
      if (current >= questions.length) return false;
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          count--;
        });
      }
      if (count <= 0) {
        moveToNextQuestion();
      }
      return count > 0;
    });
  }

  void moveToNextQuestion() {
    if (current < questions.length - 1) {
      setState(() {
        current++;
        count = 15.0;
        if (!isFront) {
          cardKey.currentState!.toggleCard();
          isFront = true;
        }
      });
      startTimer();
    } else {
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over! 🎉", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: $score/${questions.length}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Icon(Icons.emoji_events, color: Colors.amber, size: 50),
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

  void restartGame() {
    setState(() {
      current = 0;
      score = 0;
      questions = [];
    });
    getHttp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Passatempo',
            style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold, color: Colors.brown)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Text('Tempo: ${count.toInt()}s',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          questions.isEmpty
              ? CircularProgressIndicator()
              : FlipCard(
                  key: cardKey,
                  onFlip: () => setState(() => isFront = false),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Resposta correta!')),
                                    );
                                    score++;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Resposta Errada! Correta seria: ${questions[current].correctAnswer}',
                                        ),
                                      ),
                                    );
                                  }
                                  moveToNextQuestion();
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ),
          SizedBox(height: 24),
          Text(
            'Pergunta ${current + 1}/${questions.length}',
            style: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class TriviaCard extends StatelessWidget {
  final Widget filho;
  final bool isFront;
  const TriviaCard({required this.filho, required this.isFront, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFront ? Colors.brown : Colors.blueGrey,
        borderRadius: BorderRadius.circular(40),
      ),
      child: filho,
    );
  }
}
