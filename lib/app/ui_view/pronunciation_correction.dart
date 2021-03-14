import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'pinyin_annotated_paragraph.dart';

class PronunciationCorrection extends StatelessWidget {
  const PronunciationCorrection(
      {Key? key,
      required this.pinyinList,
      required this.refPinyinList,
      required this.hanziList,
      required this.refHanziList})
      : super(key: key);

  final List<String> hanziList;
  final List<String> refHanziList;
  final List<String> pinyinList;
  final List<String> refPinyinList;
  static const TextStyle correctStyle = TextStyle(color: Colors.lightBlueAccent);
  static const TextStyle errorStyle =
      TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold);

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

  SingleHanziBuilder hanziBuilder() =>
      ({required int index, required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
        // Hanzi
        final hanziStyle =
            pinyinAnnotatedHanzi.hanzi == refHanziList[index] ? correctStyle : errorStyle;
        final hanziWidget = Text(
          pinyinAnnotatedHanzi.hanzi,
          style: hanziStyle,
        );
        // Pinyin
        final wrongPinyinList =
            _calculateWrongPinyinIndex(pinyinAnnotatedHanzi.pinyin, refPinyinList[index]);
        final pinyinStyles = List.generate(pinyinAnnotatedHanzi.pinyin.length,
            (index) => wrongPinyinList.contains(index) ? errorStyle : correctStyle);
        final pinyinWidget = RichText(
            text: TextSpan(
                children: pinyinAnnotatedHanzi.pinyin
                    .split('')
                    .mapIndexed(
                        (index, element) => TextSpan(text: element, style: pinyinStyles[index]))
                    .toList()));
        return IntrinsicWidth(
          child: Column(
            children: [
              pinyinWidget,
              hanziWidget,
            ],
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
