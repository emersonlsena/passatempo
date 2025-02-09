import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passatempo/models/triva_question_model.dart';
import 'dart:async';

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
  int timeLeft = 15;
  Timer? timer;
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
      startTimer(); // Start the timer after fetching questions
    } catch (e) {
      log('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas')),
      );
    }
  }

  void startTimer() {
    timer?.cancel(); // Cancel any existing timer
    setState(() {
      timeLeft = 15; // Reset timer to 15 seconds
    });

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    if (isFront) {
      moveToNextQuestion(); // If front, just move to the next question
    } else {
      cardKey.currentState?.toggleCard();
      isFront = true;
      Future.delayed(Duration(milliseconds: 500), () {
        moveToNextQuestion();
      });
    }
  }

  void moveToNextQuestion() {
    if (current < questions.length - 1) {
      setState(() {
        current++;
        isFront = true;
      });
      startTimer(); // Restart timer for the next question
    } else {
      showGameOverDialog();
    }
  }

  void onAnswerSelected(String selectedAnswer) {
    timer?.cancel(); // Stop the timer immediately after an answer is selected

    bool isCorrect = selectedAnswer == questions[current].correctAnswer;

    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resposta correta!')),
      );
      score++;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Resposta Errada! Correta seria: ${questions[current].correctAnswer}')),
      );
    }

    if (!isFront) {
      cardKey.currentState?.toggleCard();
      isFront = true;
      Future.delayed(Duration(milliseconds: 500), () {
        moveToNextQuestion();
      });
    } else {
      moveToNextQuestion();
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

  void restartGame() {
    setState(() {
      current = 0;
      score = 0;
      questions = [];
    });

    getHttp();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 238, 255, 7),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
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
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 238, 255, 7),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(10, 10),
                ),
              ],
            ),
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 60),
          Text('$timeLeft', style: TextStyle(fontSize: 30)),
          questions.isEmpty
              ? CircularProgressIndicator()
              : FlipCard(
                  key: cardKey,
                  onFlip: () {
                    setState(() {
                      isFront = !isFront;
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
                  back: Stack(
                    children: [
                      TriviaCard(
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
                                    onTap: () => onAnswerSelected(resposta),
                                  ))
                              .toList(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 238, 154, 27),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                              )
                            ],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.flip_camera_android_rounded,
                            color: Colors.white,
                            size: 32,
                            weight: 900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          Text(
            'Pergunta ${current + 1}/${questions.length}',
            style: GoogleFonts.workSans(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 46, 114, 48),
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
            offset: Offset(10, 10),
          )
        ],
        color: isFront ? Colors.brown : Colors.blueGrey,
        borderRadius: BorderRadius.circular(40),
      ),
      child: filho,
    );
  }
}
