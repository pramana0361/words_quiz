import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:words_quiz/models/words_model.dart';

class WordsController {
  static WordsModel? wordsList;
  static WordsController? _instance;
  factory WordsController() => _instance ??= WordsController._();
  WordsController._();

  static Future<void> initialize() async {
    final String response = await rootBundle.loadString('assets/words.json');
    final data = await json.decode(response);
    wordsList = WordsModel.fromMap(data);
  }

  static List<String> ramdomWord(
      {required int wordLength, required int wordsCount}) {
    List<String> wordsByLength = wordsList!.data
        .where((element) => element.length == wordLength)
        .toList();
    List<String> selectedWords = [];
    for (int i = 0; i < wordsCount; i++) {
      selectedWords.add(wordsByLength[Random().nextInt(wordsByLength.length)]);
    }
    return selectedWords;
  }
}
