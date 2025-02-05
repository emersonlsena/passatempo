import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  final dio = Dio();

  void getHttp() async {
    final response = await dio.get('https://the-trivia-api.com/v2/questions/');
    setState(() {
      questions = (response.data as List)
          .map((item) => TrivaQuestionModel.fromJson(item))
          .toList();
    });
    for (var i in questions) {
      log(i.question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passatempo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text('User'),
                Spacer(),
                Text('Score'),
                SizedBox(
                  width: 8,
                ),
                Text('0'),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text('Perguntas 1/10'),
            SizedBox(
              height: 16,
            ),
            FlipCard(
              key: cardKey,
              front: TriviaCard(
                filho: Center(
                    child: Text(
                  questions[current].question,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                )),
              ),
              back: TriviaCard(
                filho: Center(
                  child: Column(
                    children: questions[current]
                        .options
                        .map((resposta) => ListTile(
                              title: Text(resposta),
                              onTap: () {
                                if (resposta ==
                                    questions[current].correctAnswer) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Resposta correta')));
                                  setState(() {
                                    if (current < questions.length - 1) {
                                      current++;
                                      cardKey.currentState!.toggleCard();
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Resposta Errada, correta seria: ${questions[current].correctAnswer}')));
                                  setState(() {
                                    if (current < questions.length - 1) {
                                      current++;
                                      cardKey.currentState!.toggleCard();
                                    }
                                  });
                                }
                              },
                            ))
                        .toList(),
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
  const TriviaCard({
    required this.filho,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.blueGrey, borderRadius: BorderRadius.circular(40)),
      child: filho,
    );
  }
}
