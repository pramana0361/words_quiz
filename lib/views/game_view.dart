import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:words_quiz/controllers/words_controller.dart';

class GameView extends StatefulWidget {
  const GameView({
    super.key,
  });

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final translator = GoogleTranslator();
  int _level = 1;
  late int _quizNumb;

  int point = 0;

  late List<String> _quizWords;
  late String _selectedWord;
  late List<String?> _wordPuzzle;
  late List<String?> _wordButton;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _quizNumb = 1;
    _quizWords = WordsController.ramdomWord(
        wordLength: _level > 1 ? 6 : 4, wordsCount: 5);
    _selectedWord = _quizWords.first;
    _wordPuzzle = List.filled(_selectedWord.length, "", growable: false);
    _wordButton = _selectedWord.split("");
    _wordButton.shuffle();
  }

  Widget _wordContainer(List<String?> wordPuzzle) {
    List<Widget> widgets = [];
    for (int i = 0; i < wordPuzzle.length; i++) {
      if (wordPuzzle.isEmpty) {
        widgets.add(Container(
          constraints: const BoxConstraints(minWidth: 10.0, minHeight: 10.0),
          child: Text("_", style: Theme.of(context).textTheme.headlineMedium),
        ));
      } else {
        widgets.add(Container(
          constraints: const BoxConstraints(minWidth: 10.0, minHeight: 10.0),
          child: Text(
              wordPuzzle[i]!.isEmpty ? "_" : wordPuzzle[i]!.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium),
        ));
      }
    }
    return Wrap(
      spacing: 10,
      children: widgets,
    );
  }

  void _correctAnswer() {
    setState(() {
      point += 5;
      _quizWords.removeAt(0);
      _quizNumb++;
      _selectedWord = _quizWords.first;
      _wordPuzzle = List.filled(_selectedWord.length, "", growable: false);
      _wordButton = _selectedWord.split("");
      _wordButton.shuffle();
      if (_quizNumb == 5) {
        _level++;
        _initializeGame();
      }
    });
  }

  void _wrongAnswer() {
    setState(() {
      if (point > 1) {
        point = point - 2;
      } else if (point == 1) {
        point = point - 1;
      }
      _quizWords.removeAt(0);
      _quizNumb++;
      _selectedWord = _quizWords.first;
      _wordPuzzle = List.filled(_selectedWord.length, "", growable: false);
      _wordButton = _selectedWord.split("");
      _wordButton.shuffle();
      if (_quizNumb == 5) {
        _level++;
        _initializeGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("LEVEL: $_level"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Center(
              child: Text(
                "Point: $point",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: translator.translate(_quizWords.first, from: 'en', to: 'id'),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                var data = snapshot.data;
                return FractionallySizedBox(
                  heightFactor: 1.0,
                  widthFactor: 1.0,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 50.0,
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  data.toString().toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const SizedBox(
                                  height: 50.0,
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 42,
                                  ),
                                ),
                                _wordContainer(_wordPuzzle),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          List<String> wordSplit =
                                              _selectedWord.split("");
                                          for (int idx = 0;
                                              idx < wordSplit.length;
                                              idx++) {
                                            _wordPuzzle[idx] = wordSplit[idx];
                                          }
                                          _wordButton.clear();
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            _wrongAnswer();
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text("SURRENDER"),
                                          ));
                                        });
                                      },
                                      child: const Text("Surrender")),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 50.0,
                              horizontal: 20.0,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              children: List.generate(
                                _wordButton.length,
                                (i) {
                                  if (_wordButton.isEmpty) {
                                    return const SizedBox.shrink();
                                  } else {
                                    return Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 10.0, minHeight: 10.0),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            for (int idx = 0;
                                                idx < _wordPuzzle.length;
                                                idx++) {
                                              if (_wordPuzzle[idx]!.isEmpty) {
                                                _wordPuzzle[idx] =
                                                    _wordButton[i];
                                                _wordButton.removeAt(i);
                                                break;
                                              }
                                            }
                                            if (_wordButton.isEmpty) {
                                              String result =
                                                  _wordPuzzle.join();
                                              if (result == _selectedWord) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Correct: ${_selectedWord.toUpperCase()}"),
                                                ));
                                                _correctAnswer();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Wrong! The answer is: ${_selectedWord.toUpperCase()}"),
                                                ));
                                                _wrongAnswer();
                                              }
                                            }
                                          });
                                        },
                                        child: Text(
                                            _wordButton[i]!.isEmpty
                                                ? " "
                                                : _wordButton[i]!.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
