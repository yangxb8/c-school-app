import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';

/// Represent a single example of word
class WordExample {
  final String example;
  final String meaning;
  final List<String> pinyin;
  final StorageFile audioMale;
  final StorageFile audioFemale;
  WordExample(
      {@required this.example,
        @required this.meaning,
        @required this.pinyin,
        @required this.audioMale,
        @required this.audioFemale});
}
