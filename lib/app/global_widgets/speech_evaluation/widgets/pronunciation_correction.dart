// 📦 Package imports:
import 'package:collection/collection.dart';
// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import '../../../core/utils/index.dart';
import '../../../data/model/exam/speech_evaluation_result.dart';
import '../../pinyin_annotated_paragraph.dart';

typedef HanziTapCallback = void Function(int index);

class PronunciationCorrection extends StatelessWidget {
  PronunciationCorrection({
    Key? key,
    required this.sentenceInfo,
    required this.refPinyinList,
    required this.refHanziList,
    required this.currentFocusedHanziIndex,
    this.hanziTapCallback,
  })  : hanziList = PinyinUtil.appendPunctuation(
            origin: sentenceInfo.words!
                .map((w) =>
                    w.referenceWord!.isNotEmpty ? w.referenceWord! : w.word!)
                .toList(),
            ref: refHanziList),
        pinyinList = PinyinUtil.appendPunctuation(
            origin: sentenceInfo.words!.map((w) => w.pinyin).toList(),
            ref: refPinyinList),
        super(key: key);

  static const colorScore100 = Colors.blueAccent;

  static const colorScore0 = Colors.redAccent;

  /// Recognized hanzi list
  final List<String> hanziList;

  /// Recognized pinyin list
  final List<String> pinyinList;

  /// Expected hanzi list
  final List<String> refHanziList;

  /// Expected pinyin list
  final List<String> refPinyinList;

  /// SentenceInfo for reference
  final SentenceInfo sentenceInfo;

  /// Which hanzi is been focus now
  final RxInt currentFocusedHanziIndex;

  final HanziTapCallback? hanziTapCallback;

  /// Return list of index where pinyin doesn't match refPinyin
  List<int> _calculateWrongPinyinIndex(String pinyin, String refPinyin) {
    final refPinyinList = refPinyin.split('');
    final list = <int>[];
    pinyin.split('').forEachIndexed((index, element) {
      if (element != refPinyinList[index]) {
        list.add(index);
      }
    });
    return list;
  }

  /// Get color of score. 100 to be blue and 0 to be red
  TextStyle _getHanziTextStyle(int index, int focusedIndex) {
    final isWrong = hanziList[index] == refHanziList[index];
    var score = 100.0;
    if (hanziList[index].isSingleHanzi) {
      final hanziIndex = hanziList.indexWithoutPunctuation(index);
      score = sentenceInfo.words![hanziIndex].displaySuggestedScore;
    }
    return TextStyle(
        color: Color.lerp(colorScore0, colorScore100, score / 100),
        fontWeight: isWrong ? FontWeight.bold : FontWeight.normal,
        decoration: index == focusedIndex ? TextDecoration.underline : null,
        decorationStyle: TextDecorationStyle.double,
        decorationThickness: 2.0);
  }

  SingleHanziBuilder hanziBuilder() => (
          {required int index,
          required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
        // Hanzi
        final hanziWidget = ObxValue<RxInt>(
            (focusedIndex) => Text(
                  pinyinAnnotatedHanzi.hanzi,
                  style: _getHanziTextStyle(index, focusedIndex.value),
                ),
            currentFocusedHanziIndex);
        // Pinyin
        final wrongPinyinList = _calculateWrongPinyinIndex(
            pinyinAnnotatedHanzi.pinyin, refPinyinList[index]);
        final pinyinStyles = List.generate(
            pinyinAnnotatedHanzi.pinyin.length,
            (index) => !wrongPinyinList.contains(index)
                ? const TextStyle(color: colorScore100)
                : const TextStyle(
                    color: colorScore0, fontWeight: FontWeight.bold));
        final pinyinWidget = RichText(
            text: TextSpan(
                children: pinyinAnnotatedHanzi.pinyin
                    .split('')
                    .mapIndexed((index, element) =>
                        TextSpan(text: element, style: pinyinStyles[index]))
                    .toList()));
        return SimpleGestureDetector(
          onTap: () {
            if (!pinyinAnnotatedHanzi.isPunctuation) {
              final indexWithoutPunctuation =
                  hanziList.indexWithoutPunctuation(index);
              currentFocusedHanziIndex.value = indexWithoutPunctuation;
              if (hanziTapCallback != null) {
                hanziTapCallback!(indexWithoutPunctuation);
              }
            }
          },
          child: IntrinsicWidth(
            child: Column(
              children: [
                pinyinWidget,
                hanziWidget,
              ],
            ),
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    return PinyinAnnotatedParagraph(
      paragraph: hanziList.join(),
      pinyins: pinyinList,
      spacing: 5.0,
      defaultTextStyle: const TextStyle(color: colorScore100),
      singleHanziBuilder: hanziBuilder(),
    );
  }
}
