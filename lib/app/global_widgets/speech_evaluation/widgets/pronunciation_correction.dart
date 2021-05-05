// 📦 Package imports:
import 'package:collection/collection.dart';
// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../../../core/utils/index.dart';
import '../../../data/model/exam/speech_evaluation_result.dart';
import '../../pinyin_annotated_paragraph.dart';

typedef HanziTapCallback = void Function(int index);

class PronunciationCorrection extends StatelessWidget {
  factory PronunciationCorrection({
    required SentenceInfo sentenceInfo,
    required List<String> refPinyinList,
    required List<String> refHanziList,
    required RxInt currentFocusedHanziIndex,
    HanziTapCallback? hanziTapCallback,
  }) {
    // If there is added hanzi in result, adjust refHanzi before appending punctuation.
    final refPinyinListCopy = refPinyinList.sublist(0);
    final refHanziListCopy = refHanziList.sublist(0);
    final resultHanzi = sentenceInfo.words!
        .map((w) => w.referenceWord!.isNotEmpty ? w.referenceWord! : w.word!)
        .toList();
    final addedHanzi =
        resultHanzi.allIndexWhere((s) => s == _addedHanziRepresentative);
    if (addedHanzi.isNotEmpty) {
      addedHanzi.forEach((index) {
        refHanziListCopy.insert(index, _addedHanziRepresentative);
        refPinyinListCopy.insert(index, '');
      });
    }
    final resultPinyin = sentenceInfo.words!.map((w) => w.pinyin).toList();
    return PronunciationCorrection._internal(
        sentenceInfo: sentenceInfo,
        refPinyinList: refPinyinListCopy,
        refHanziList: refHanziListCopy,
        hanziList: PinyinUtil.appendPunctuation(
            origin: resultHanzi,
            refHanziList: refHanziListCopy,
            ignoreList: [_addedHanziRepresentative]),
        pinyinList: PinyinUtil.appendPunctuation(
            origin: resultPinyin,
            refHanziList: refHanziListCopy,
            ignoreList: [_addedHanziRepresentative]),
        currentFocusedHanziIndex: currentFocusedHanziIndex);
  }

  PronunciationCorrection._internal({
    Key? key,
    required this.sentenceInfo,
    required this.refPinyinList,
    required this.refHanziList,
    required this.currentFocusedHanziIndex,
    required this.hanziList,
    required this.pinyinList,
    this.hanziTapCallback,
  }) : super(key: key);

  static final colorBad = '#FF6B6F'.toColor();
  static final colorOk = '#FF9774'.toColor();
  static final colorGreat = '#1ED7A6'.toColor();

  /// Which hanzi is been focus now
  final RxInt currentFocusedHanziIndex;

  /// Recognized hanzi list
  final List<String> hanziList;

  final HanziTapCallback? hanziTapCallback;

  /// Recognized pinyin list
  final List<String> pinyinList;

  /// Expected hanzi list
  final List<String> refHanziList;

  /// Expected pinyin list
  final List<String> refPinyinList;

  /// SentenceInfo for reference
  final SentenceInfo sentenceInfo;

  /// Added hanzi will be return as '*' now. This might change in the future.
  static const _addedHanziRepresentative = '*';

  static const _hanziFontSize = 20.0;
  static const _pinyinFontSize = 20.0;

  /// Get textStyle of pinyin
  List<TextStyle> _getPinyinStyles(int index) {
    final wordIndex = hanziList.indexWithoutPunctuation(index,
        ignoreList: [_addedHanziRepresentative]);
    final styleList = <TextStyle>[];
    final phoneInfos = sentenceInfo.words![wordIndex].phoneInfos!;
    phoneInfos.forEach((phoneInfo) {
      final style = TextStyle(
          fontSize: _pinyinFontSize,
          color: _getColorOfScore(phoneInfo.displayPronAccuracy),
          decorationStyle: TextDecorationStyle.double,
          decorationThickness: 2.0);
      final phone = phoneInfo.referencePhone!.isNotEmpty
          ? phoneInfo.referencePhone!
          : phoneInfo.detectedPhone!;
      var phoneLength = phone.length;
      // Remove tone digit(1-4) from phoneLength, as we don't have this in
      // displayed phone
      if (PinyinUtil.toneDigitPtn.hasMatch(phone)) {
        phoneLength--;
      }
      0.rangeTo(phoneLength - 1).forEach((_) => styleList.add(style));
    });
    return styleList;
  }

  /// Get textStyle of hanzi
  TextStyle _getHanziTextStyle(int index) {
    final isWrong = hanziList[index] == refHanziList[index];
    var score = 100.0;
    // Added hanzi is considered wrong
    if (hanziList[index] == _addedHanziRepresentative) {
      score = 0.0;
    } else if (hanziList[index].isSingleHanzi) {
      final hanziIndex = hanziList.indexWithoutPunctuation(index,
          ignoreList: [_addedHanziRepresentative]);
      score = sentenceInfo.words![hanziIndex].displaySuggestedScore;
    }
    return TextStyle(
        fontSize: _hanziFontSize,
        color: _getColorOfScore(score),
        fontWeight: isWrong ? FontWeight.bold : FontWeight.normal,
        decorationStyle: TextDecorationStyle.double,
        decorationThickness: 2.0);
  }

  /// Get color of score. 100 to be green and 0 to be red
  Color _getColorOfScore(double score) {
    assert(score >= 0 && score <= 100);
    if (score < 60) {
      return colorBad;
    } else if (score < 80) {
      return colorOk;
    } else {
      return colorGreat;
    }
  }

  SingleHanziBuilder hanziBuilder() => (
          {required int index,
          required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
        // Hanzi
        final hanziWidget = Text(
          pinyinAnnotatedHanzi.hanzi,
          style: _getHanziTextStyle(index),
        );
        // Pinyin
        late final pinyinWidget;
        if (!pinyinAnnotatedHanzi.isHanzi) {
          pinyinWidget = const SizedBox.shrink();
        } else {
          final pinyinStyles = _getPinyinStyles(index);
          pinyinWidget = RichText(
              text: TextSpan(
                  children: pinyinAnnotatedHanzi.pinyin
                      .split('')
                      .mapIndexed((index, element) =>
                          TextSpan(text: element, style: pinyinStyles[index]))
                      .toList()));
        }

        return SimpleGestureDetector(
          onTap: () {
            if (pinyinAnnotatedHanzi.isHanzi) {
              final indexWithoutPunctuation =
                  hanziList.indexWithoutPunctuation(index);
              if (currentFocusedHanziIndex.value == indexWithoutPunctuation) {
                currentFocusedHanziIndex.value = -1;
              } else {
                currentFocusedHanziIndex.value = indexWithoutPunctuation;
              }
              if (hanziTapCallback != null) {
                hanziTapCallback!(indexWithoutPunctuation);
              }
            }
          },
          child: ObxValue<RxInt>(
            (focusedIndex) => IntrinsicWidth(
              child: Column(
                children: [
                  pinyinWidget,
                  hanziWidget,
                ],
              ),
            ).padding(all: 2).border(
                all: 1,
                style: focusedIndex.value == index
                    ? BorderStyle.solid
                    : BorderStyle.none),
            currentFocusedHanziIndex,
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    return PinyinAnnotatedParagraph(
      paragraph: hanziList.join(),
      pinyins: pinyinList,
      spacing: 5.0,
      defaultTextStyle: TextStyle(color: colorGreat, fontSize: _hanziFontSize),
      singleHanziBuilder: hanziBuilder(),
    );
  }
}

extension HanziListUtil on List<String> {
  /// Convert the index with punctuation to index without it.
  int indexWithoutPunctuation(index, {List<String> ignoreList = const []}) {
    var indexCopy = index;
    final _punctuationPositions = allIndexWhere(
        (e) => !(e as String).isSingleHanzi && !ignoreList.contains(e));
    for (var pIndex in _punctuationPositions) {
      if (indexCopy >= pIndex) {
        indexCopy++;
      } else {
        break;
      }
    }
    return indexCopy;
  }
}
