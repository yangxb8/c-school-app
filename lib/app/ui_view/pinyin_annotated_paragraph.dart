// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../../service/lecture_service.dart';
import '../../util/extensions.dart';
import '../model/word.dart';

class PinyinAnnotatedParagraph extends StatelessWidget {
  final String paragraph;
  final Word centerWord;
  final List<Word> linkedWords;
  final List<String> pinyins;
  final TextStyle defaultTextStyle;
  final TextStyle centerWordTextStyle;
  final TextStyle linkedWordTextStyle;
  final TextStyle pinyinTextStyle;
  final bool showPinyins;
  final double spacing;
  final double runSpacing;

  const PinyinAnnotatedParagraph(
      {Key key,
      @required this.paragraph,
      @required this.pinyins,
      @required this.defaultTextStyle,
      this.centerWord,
      this.linkedWords,
      this.centerWordTextStyle,
      this.linkedWordTextStyle,
      this.pinyinTextStyle,
      this.showPinyins = true,
      this.spacing = 0,
      this.runSpacing = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hanzis = _generateHanzis();
    return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: hanzis.map((hanzi) => _buildSingleHanzi(pinyinAnnotatedHanzi: hanzi)).toList());
  }

  Widget _buildSingleHanzi({@required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
    final pinyinRow = showPinyins && pinyinAnnotatedHanzi.pinyin.isNotEmpty
        ? [Text(pinyinAnnotatedHanzi.pinyin, style: pinyinAnnotatedHanzi.pinyinStyle)]
        : [];
    final inner = IntrinsicWidth(
      child: Column(
        children: [
          ...pinyinRow,
          Text(pinyinAnnotatedHanzi.hanzi, style: pinyinAnnotatedHanzi.hanziStyle),
        ],
      ),
    );
    if (pinyinAnnotatedHanzi.type != ParagraphHanziType.linked) {
      return inner;
    } else {
      return SimpleGestureDetector(
          onTap: () =>
              Get.find<LectureService>().showSingleWordCard(pinyinAnnotatedHanzi.linkedWord),
          child: inner);
    }
  }

  List<PinyinAnnotatedHanzi> _generateHanzis() {
    // Divide paragraph by center word and linked word
    final dividerWords = <String>[];
    if (centerWord != null) dividerWords.add(centerWord.wordAsString);
    if (linkedWords != null) {
      dividerWords.addAll(linkedWords.map((w) => w.wordAsString));
    }
    final keywordsSeparatedParagraph = _divideExample(dividerWords, paragraph);
    return List<PinyinAnnotatedHanzi>.generate(paragraph.length, (idx) {
      final hanzi = paragraph[idx];
      var pinyin = hanzi.isSingleHanzi ? pinyins[idx] : '';
      final hanziTypeAndRelatedWord = _calculateHanziType(
          hanziIdx: idx, keywordsSeparatedParagraph: keywordsSeparatedParagraph);
      final hanziType = hanziTypeAndRelatedWord.keys.single;
      final linkedWord = hanziTypeAndRelatedWord.values.single;
      var hanziStyle;
      switch (hanziType) {
        case ParagraphHanziType.linked:
          hanziStyle = linkedWordTextStyle ?? defaultTextStyle;
          break;
        case ParagraphHanziType.center:
          hanziStyle = centerWordTextStyle ?? defaultTextStyle;
          break;
        default:
          hanziStyle = defaultTextStyle;
          break;
      }
      return PinyinAnnotatedHanzi(
          hanzi: hanzi,
          pinyin: pinyin,
          hanziStyle: hanziStyle,
          pinyinStyle: pinyinTextStyle,
          type: hanziType,
          linkedWord: linkedWord);
    });
  }

  Map<ParagraphHanziType, Word> _calculateHanziType(
      {@required int hanziIdx, @required List<String> keywordsSeparatedParagraph}) {
    var totalIdx = 0;
    var result;
    for (final part in keywordsSeparatedParagraph) {
      // Target hanzi is in range of this part of paragraph
      final linkedWordList = linkedWords?.filter((w) => w.wordAsString == part) ?? [];
      if (totalIdx + part.length > hanziIdx) {
        if (centerWord?.wordAsString == part) {
          result = {ParagraphHanziType.center: null};
          break;
        } else if (linkedWordList.isNotEmpty) {
          result = {ParagraphHanziType.linked: linkedWordList.single};
          break;
        } else {
          result = {ParagraphHanziType.normal: null};
          break;
        }
      }
      // If hanziIdx is not found within this part, add totalIdx and move to next part
      else {
        totalIdx += part.length;
      }
    }
    return result;
  }

  /// Divide sentence into List of String by keyword(s)
  List<String> _divideExample(dynamic keyword, dynamic example) {
    if (keyword == null || keyword.length == 0) return [example];
    var exampleDivided = <String>[];
    // When we have multiple keyword
    if (keyword is List<String>) {
      var keywordSet = keyword.toSet();
      var exampleDivided = example;
      keywordSet.forEach((k) => exampleDivided = _divideExample(k, exampleDivided));
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
      @required this.linkedWord});
}

enum ParagraphHanziType { normal, linked, center }
