// 🐦 Flutter imports:
// 🌎 Project imports:

// 📦 Package imports:
import 'package:collection/collection.dart';
// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import '../core/utils/index.dart';
import '../data/model/exam/speech_evaluation_result.dart';
import 'pinyin_annotated_paragraph.dart';

typedef HanziTapCallback = void Function(int index);

class PronunciationCorrection extends StatelessWidget {
  PronunciationCorrection(
      {Key? key,
      required this.result,
      required this.refPinyinList,
      required this.refHanziList,
      this.hanziTapCallback})
      : hanziList = PinyinUtil.appendPunctuation(
            origin:
                result.words!.map((w) => w.referenceWord ?? w.word!).toList(),
            ref: refHanziList),
        pinyinList = PinyinUtil.appendPunctuation(
            origin: result.words!.map((w) => w.pinyin).toList(),
            ref: refHanziList),
        super(key: key);

  static const TextStyle correctStyle =
      TextStyle(color: Colors.lightBlueAccent);

  static const TextStyle errorStyle =
      TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold);

  final List<String> hanziList;
  final HanziTapCallback? hanziTapCallback;
  final List<String> pinyinList;
  final List<String> refHanziList;
  final List<String> refPinyinList;
  final SentenceInfo result;

  /// Return list of index where pinyin doesn't match refPinyin
  List<int> _calculateWrongPinyinIndex(String pinyin, String refPinyin) {
    final refPinyinList = refPinyin.split('');
    final list = <int>[];
    pinyin.split('').forEachIndexed((index, element) {
      if (element == refPinyinList[index]) {
        list.add(index);
      }
    });
    return list;
  }

  SingleHanziBuilder hanziBuilder() => (
          {required int index,
          required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
        // Hanzi
        final hanziStyle = pinyinAnnotatedHanzi.hanzi == refHanziList[index]
            ? correctStyle
            : errorStyle;
        final hanziWidget = Text(
          pinyinAnnotatedHanzi.hanzi,
          style: hanziStyle,
        );
        // Pinyin
        final wrongPinyinList = _calculateWrongPinyinIndex(
            pinyinAnnotatedHanzi.pinyin, refPinyinList[index]);
        final pinyinStyles = List.generate(
            pinyinAnnotatedHanzi.pinyin.length,
            (index) =>
                wrongPinyinList.contains(index) ? errorStyle : correctStyle);
        final pinyinWidget = RichText(
            text: TextSpan(
                children: pinyinAnnotatedHanzi.pinyin
                    .split('')
                    .mapIndexed((index, element) =>
                        TextSpan(text: element, style: pinyinStyles[index]))
                    .toList()));
        return SimpleGestureDetector(
          onTap: () {
            if (hanziTapCallback != null) {
              hanziTapCallback!(index);
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
      defaultTextStyle: correctStyle,
      singleHanziBuilder: hanziBuilder(),
    );
  }
}
