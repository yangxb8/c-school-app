import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:supercharged/supercharged.dart';
import '../models/word.dart';
import '../../util/extensions.dart'

class PinyinAnnotatedParagraph extends StatelessWidget {
  final String paragraph;
  final Word centerWord;
  final List<Word> linkedWords;
  final List<String> pinyins;
  final TextStyle defaultTextStyle;
  final TextStyle centerWordTextStyle;
  final TextStyle linkedWordTextStyle;
  final TextStyle pinyinTextStyle;

  const PinyinAnnotatedParagraph(
      {Key key,
      @required this.paragraph,
      @required this.pinyins,
      @required this.defaultTextStyle,
      this.centerWord,
      this.linkedWords,
      this.centerWordTextStyle,
      this.linkedWordTextStyle,
      this.pinyinTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<PinyinAnnotatedHanzi> hanzis = _generateHanzis();
    return Wrap(children: List<Widget>.generate(hanzis.length,(hanziIdx)=>
        _buildSingleHanzi(hanzis[hanziIdx]);
    ));
  }

  Widget _buildSingleHanzi({@required PinyinAnnotatedHanzi paragraphHanzi}) {
    final inner = IntrinsicWidth(
      child: Column(
        children: [
            Text(paragraphHanzi.pinyin,style: pinyinTextStyle),
            Text(paragraphHanzi.hanzi,style: textStyle),
        ],
      ),
    );
    if(hanziType != ParagraphHanziType.linked){
        return inner;
    } else {
        return SimpleGestureDetector(
            onTap: Get.find<ClassService>().showSingleWordCard(linkedWord),
            child: inner
        )
    }
  }

  List<PinyinAnnotatedHanzi> _generateHanzis() {
    var textStyle;
    switch(hanziType){
    case ParagraphHanziType.linked:
        textStyle = linkedWordTextStyle?? defaultTextStyle;
        break;
    case ParagraphHanziType.center:
        textStyle = centerWordTextStyle?? defaultTextStyle;
        break;
    default:
        textStyle = defaultTextStyle;
        break;    
    }
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

  bool _isCenterWord(String word) => centerWord.wordAsString == word;

  bool _isLinkedWord(String word) => linkedWords.count((word)=>word.wordAsString == word)>0;
}

class PinyinAnnotatedHanzi {
    final String hanzi;
    final String pinyin;
    final TextStyle hanziStyle;
    final TextStyle pinyinStyle;
    final ParagraphHanziType type;
    final Word linkedWord;

    const PinyinAnnotatedHanzi(
      {Key key,
      @required this.hanzi,
      @required this.pinyin,
      @required this.hanziStyle,
      @required this.pinyinStyle,
      @required this.type,
      @required this.linkedWord})
      : super(key: key);
}

enum ParagraphHanziType{
    normal, linked, center
}
