import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar perguntas')));
    }
    // for (var i in questions) {
    // log(i.question);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Passatempo',
          style: GoogleFonts.workSans(
              fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color.fromARGB(255, 104, 138, 198),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
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
                SizedBox(
                  width: 8,
                ),
                Text(
                  '${score}',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Pergunta ${current + 1}/${questions.length}',
              style: GoogleFonts.workSans(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 46, 114, 48),
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
                        //questions.isNotEmpty
                        questions[current].question,
                        //: 'Loading...',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),
                    ),
                    back: TriviaCard(
                      isFront: false,
                      filho: Center(
                        child: Column(
                            children: //questions.isNotEmpty
                                questions[current]
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
                                            if (resposta ==
                                                questions[current]
                                                    .correctAnswer) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Resposta correta')));
                                              score++;
                                              setState(() {
                                                if (current <
                                                    questions.length - 1) {
                                                  current++;
                                                  cardKey.currentState!
                                                      .toggleCard();
                                                }
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Resposta Errada, correta seria: ${questions[current].correctAnswer}')));
                                              setState(() {
                                                if (current <
                                                    questions.length - 1) {
                                                  current++;
                                                  cardKey.currentState!
                                                      .toggleCard();
                                                }
                                              });
                                            }
                                          },
                                        ))
                                    .toList()
                            //: [],
                            ),
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
      duration: Duration(seconds: 5),
      margin: EdgeInsets.all(5),
      constraints: BoxConstraints(minHeight: 250),
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: isFront ? Colors.brown : Colors.blueGrey,
          borderRadius: BorderRadius.circular(40)),
      child: filho,
    );
  }
}
