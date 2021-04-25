// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:collection/collection.dart';
// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import '../core/utils/index.dart';
import '../data/model/word/word.dart';
// 🌎 Project imports:
import '../core/service/lecture_service.dart';

typedef SingleHanziBuilder = Widget Function(
    {required int index, required PinyinAnnotatedHanzi pinyinAnnotatedHanzi});

typedef OnHanziTap = void Function(int index);

class PinyinAnnotatedParagraph extends StatelessWidget {
  const PinyinAnnotatedParagraph(
      {Key? key,
      required this.paragraph,
      required this.pinyins,
      this.maxLines,
      required this.defaultTextStyle,
      this.centerWord,
      this.linkedWords,
      centerWordTextStyle,
      linkedWordTextStyle,
      pinyinTextStyle,
      this.leadingWidget,
      this.showPinyins = true,
      this.spacing = 0,
      this.runSpacing = 0,
      this.singleHanziBuilder,
      this.onHanziTap})
      : pinyinTextStyle = pinyinTextStyle ?? defaultTextStyle,
        linkedWordTextStyle = linkedWordTextStyle ?? defaultTextStyle,
        centerWordTextStyle = centerWordTextStyle ?? defaultTextStyle,
        super(key: key);

  /// Word to apply center word style
  final Word? centerWord;

  /// Text style for center word
  final TextStyle centerWordTextStyle;

  /// TextStyle of paragraph and others if not other text style is specified
  final TextStyle defaultTextStyle;

  /// Widget been display before paragraph
  final Widget? leadingWidget;

  /// Word that can be linked to other words
  final List<Word>? linkedWords;

  /// Text style for linked word
  final TextStyle linkedWordTextStyle;

  /// Max line this paragraph can occupy. If this is set, fontSize will be adjusted to fit
  final int? maxLines;

  final OnHanziTap? onHanziTap;

  /// Paragraph of chinese chars
  final String paragraph;

  /// Pinyins of paragraph
  final List<String> pinyins;

  /// Text style for pinyin
  final TextStyle pinyinTextStyle;

  /// Spacing of lines
  final double runSpacing;

  /// False to hide pinyin
  final bool showPinyins;

  /// When you need some custom presentation of hanzi
  final SingleHanziBuilder? singleHanziBuilder;

  /// Spacing of every chinese char
  final double spacing;

  Widget _buildSingleHanzi(
      {required int index,
      required PinyinAnnotatedHanzi pinyinAnnotatedHanzi}) {
    // If builder is provided, use it to build hanzi
    if (singleHanziBuilder != null) {
      return singleHanziBuilder!(
          index: index, pinyinAnnotatedHanzi: pinyinAnnotatedHanzi);
    }
    final pinyinRow = showPinyins
        ? [
            Text(pinyinAnnotatedHanzi.pinyin,
                style: pinyinAnnotatedHanzi.pinyinStyle)
          ]
        : [];
    final inner = IntrinsicWidth(
      child: SimpleGestureDetector(
        onTap: onHanziTap == null ? null : () => onHanziTap!(index),
        child: Column(
          children: [
            ...pinyinRow,
            Text(pinyinAnnotatedHanzi.hanzi,
                style: pinyinAnnotatedHanzi.hanziStyle),
          ],
        ),
      ),
    );
    if (pinyinAnnotatedHanzi.type != ParagraphHanziType.linked) {
      return inner;
    } else {
      return SimpleGestureDetector(
          onTap: () => Get.find<LectureService>()
              .showSingleWordCard(pinyinAnnotatedHanzi.linkedWord),
          child: inner);
    }
  }

  List<PinyinAnnotatedHanzi> _generateHanzis(
      TextStyle defaultStyle,
      TextStyle pinyinStyle,
      TextStyle centerWordStyle,
      TextStyle linkedWordStyle) {
    // Divide paragraph by center word and linked word
    final dividerWords = <String>[];
    if (centerWord != null) dividerWords.add(centerWord!.wordAsString);
    if (linkedWords != null) {
      dividerWords.addAll(linkedWords!.map((w) => w.wordAsString));
    }
    final keywordsSeparatedParagraph = _divideExample(dividerWords, paragraph);
    return List<PinyinAnnotatedHanzi>.generate(paragraph.length, (idx) {
      final hanzi = paragraph[idx];
      var pinyin = hanzi.isSingleHanzi ? pinyins[idx] : '';
      final hanziTypeAndRelatedWord = _calculateHanziType(
          hanziIdx: idx,
          keywordsSeparatedParagraph: keywordsSeparatedParagraph);
      final hanziType = hanziTypeAndRelatedWord.keys.single;
      final linkedWord = hanziTypeAndRelatedWord.values.single;
      var hanziStyle;
      switch (hanziType) {
        case ParagraphHanziType.linked:
          hanziStyle = linkedWordStyle;
          break;
        case ParagraphHanziType.center:
          hanziStyle = centerWordStyle;
          break;
        default:
          hanziStyle = defaultStyle;
          break;
      }
      return PinyinAnnotatedHanzi(
          hanzi: hanzi,
          pinyin: pinyin,
          hanziStyle: hanziStyle,
          pinyinStyle: pinyinStyle,
          type: hanziType,
          linkedWord: linkedWord);
    });
  }

  Map<ParagraphHanziType, Word> _calculateHanziType(
      {required int hanziIdx,
      required List<String> keywordsSeparatedParagraph}) {
    var totalIdx = 0;
    late var result;
    for (final part in keywordsSeparatedParagraph) {
      // Target hanzi is in range of this part of paragraph
      final linkedWordList =
          (linkedWords?.where((w) => w.wordAsString == part) ?? []);
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
    return const [];
  }

  List _calculateFontSize(
      BoxConstraints size, String text, TextStyle originStyle, int? maxLines) {
    // Apply wrap spacing to text style to correctly calculate the font size
    var style = originStyle.copyWith(letterSpacing: spacing);
    var span = TextSpan(
      style: style,
      text: text,
    );

    var userScale = Get.textScaleFactor;

    int left;
    int right;
    const minFontSize = 12;
    const maxFontSize = double.infinity;
    const stepGranularity = 1;

    var defaultFontSize = style.fontSize!.clamp(minFontSize, maxFontSize);
    var defaultScale = defaultFontSize * userScale / style.fontSize!;
    if (_checkTextFits(span, defaultScale, maxLines, size)) {
      return [defaultFontSize * userScale, true];
    }

    left = (minFontSize / stepGranularity).floor();
    right = (defaultFontSize / stepGranularity).ceil();

    var lastValueFits = false;
    while (left <= right) {
      var mid = (left + (right - left) / 2).toInt();
      double scale;
      scale = mid * userScale * stepGranularity / style.fontSize!;
      if (_checkTextFits(span, scale, maxLines, size)) {
        left = mid + 1;
        lastValueFits = true;
      } else {
        right = mid - 1;
      }
    }

    if (!lastValueFits) {
      right += 1;
    }

    double fontSize;
    fontSize = right * userScale * stepGranularity;

    return [fontSize, lastValueFits];
  }

  bool _checkTextFits(
      TextSpan text, double? scale, int? maxLines, BoxConstraints constraints) {
    var tp = TextPainter(
      text: text,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      textScaleFactor: scale ?? 1,
      maxLines: maxLines,
    );

    tp.layout(maxWidth: constraints.maxWidth);

    return !(tp.didExceedMaxLines ||
        tp.height > constraints.maxHeight ||
        tp.width > constraints.maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, originSize) {
      // Adjust font size to fit in lines
      //TODO: 0.8 is magic number, we need to calculate font size properly
      var size = originSize.copyWith(maxWidth: originSize.maxWidth * 0.8);
      var adjustedDefaultFontSize = defaultTextStyle.fontSize;
      var adjustedPinyinFontSize = pinyinTextStyle.fontSize;
      if (maxLines != null) {
        adjustedDefaultFontSize =
            _calculateFontSize(size, paragraph, defaultTextStyle, maxLines)[0];
        // If pinyin has its own style, adjust its font size too
        adjustedPinyinFontSize = _calculateFontSize(
            size, pinyins.join(), pinyinTextStyle, maxLines)[0];
      }
      final adjustedDefaultTextStyle =
          defaultTextStyle.copyWith(fontSize: adjustedDefaultFontSize);
      final adjustedPinyinTextStyle =
          pinyinTextStyle.copyWith(fontSize: adjustedPinyinFontSize);
      final adjustedCenterWordTextStyle =
          centerWordTextStyle.copyWith(fontSize: adjustedDefaultFontSize);
      final adjustedLinkedWordTextStyle =
          linkedWordTextStyle.copyWith(fontSize: adjustedDefaultFontSize);
      // Build single hanzi
      final elements =
          leadingWidget == null ? <Widget>[] : <Widget>[leadingWidget!];
      elements.addAll(_generateHanzis(
              adjustedDefaultTextStyle,
              adjustedPinyinTextStyle,
              adjustedCenterWordTextStyle,
              adjustedLinkedWordTextStyle)
          .mapIndexed((index, hanzi) =>
              _buildSingleHanzi(index: index, pinyinAnnotatedHanzi: hanzi)));
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing,
          runSpacing: runSpacing,
          children: elements);
    });
  }
}

class PinyinAnnotatedHanzi {
  const PinyinAnnotatedHanzi(
      {Key? key,
      required this.hanzi,
      required this.pinyin,
      required this.hanziStyle,
      required this.pinyinStyle,
      required this.type,
      required this.linkedWord});

  final String hanzi;
  final TextStyle hanziStyle;
  final Word linkedWord;
  final String pinyin;
  final TextStyle pinyinStyle;
  final ParagraphHanziType type;

  bool get isPunctuation => pinyin.isEmpty;
}

enum ParagraphHanziType { normal, linked, center }
