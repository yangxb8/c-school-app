import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class PinyinAnnotatedParagraph extends StatelessWidget {
  final String paragraph;
  final String centerWord;
  final List<String> linkedWords;
  final List<String> pinyins;
  final TextStyle defaultTextStyle;
  final TextStyle centerWordTextStyle;
  final TextStyle linkedWordTextStyle;

  const PinyinAnnotatedParagraph(
      {Key key,
      @required this.paragraph,
      @required this.pinyins,
      @required this.defaultTextStyle,
      this.centerWord,
      this.linkedWords,
      this.centerWordTextStyle,
      this.linkedWordTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /// Divide sentence into List of String by keyword(s)
  List<String> _divideExample(dynamic keyword, dynamic example) {
    var exampleDivided = <String>[];
    // When we have multiple keyword
    if (keyword is List<String>) {
      var keywordSet = keyword.toSet();
      var exampleDivided = example;
      keywordSet
          .forEach((k) => exampleDivided = _divideExample(k, exampleDivided));
      return exampleDivided;
    }
    // When the String is already divided before
    if (example is List<String>) {
      example.forEach((e) {
        if (e.contains(keyword)) {
          exampleDivided.addAll(_divideExample(keyword, e));
        } else {
          exampleDivided.add(e);
        }
      });
      return exampleDivided;
    } else if (example is String) {
      example.split(keyword).forEachIndexed((index, part) {
        exampleDivided.add(part);
        exampleDivided.add(keyword);
      });
      // Remove the last null we add
      exampleDivided.removeLast();
      exampleDivided.removeWhere((currentValue) => currentValue.isEmpty);
      return exampleDivided;
    }
    return null;
  }

  bool _isCenterWord(String word) => centerWord == word;

  bool _isLinkedWord(String word) => linkedWords.contains(word);

}
