import 'dart:math';

import 'package:c_school_app/app/models/word_example.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flip/flip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import '../models/word.dart';
import '../../i18n/review_words.i18n.dart';

const cardAspectRatio = 12.0 / 22.0;
const BUTTON_SIZE = 25.0;
const verticalInset = 8.0;
const DEFAULT_IMAGE = 'assets/review_panel/image_01.png';

class WordCard extends StatelessWidget {
  final Word word;
  final double delta;
  final WordCardController controller;
  WordCard({@required this.word, this.delta = 0.0})
      : controller = Get.put(WordCardController(word), tag: word.wordId);

  @override
  Widget build(BuildContext context) {
    var hint = SimpleGestureDetector(
      onTap: controller.toggleHint,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
        child: Obx(
          () => SimpleTooltip(
            tooltipTap: controller.toggleHint,
            tooltipDirection: TooltipDirection.down,
            borderColor: Colors.transparent,
            show: controller.isHintShown.value,
            ballonPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            maxWidth: Get.width * 0.7,
            content: Text(
              word.hint,
              style: ReviewWordsTheme.wordCardHint,
            ),
            child: FaIcon(FontAwesomeIcons.lightbulb,
                color: controller.isHintShown.value
                    ? ReviewWordsTheme.lightYellow
                    : ReviewWordsTheme.lightBlue,
                size: BUTTON_SIZE),
          ),
        ),
      ),
    );
    var frontCardContent = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...word.wordMeanings
                        .map((e) => Text(
                              e.meaning,
                              style: ReviewWordsTheme.wordCardMeaning,
                            ))
                        .toList(),
                    if (!word.hint.isNullOrBlank) hint else Container()
                  ],
                ),
              ],
            ).backgroundColor(ReviewWordsTheme.lightBlue),
            flex: 11),
        Expanded(
            child: word.pic?.url == null
                ? Image.asset(
                    DEFAULT_IMAGE,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: word.pic.url,
                    placeholder: (context, url) => SizedBox(
                          width: 200.0,
                          height: 100.0,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(),
                          ),
                        ),
                    errorWidget: (context, url, error) => Image.asset(
                          DEFAULT_IMAGE,
                          fit: BoxFit.cover,
                        )),
            flex: 10)
      ],
    );
    var favoriteIcon = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => IconButton(
            splashRadius: 0.01,
            icon: FaIcon(FontAwesomeIcons.solidHeart),
            // key: favoriteButtonKey,
            color: controller.isWordLiked()
                ? ReviewWordsTheme.lightYellow
                : Colors.grey,
            iconSize: BUTTON_SIZE * 1.2,
            onPressed: () => controller.toggleFavoriteCard(),
          ).paddingOnly(top: 10, right: 10),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SimpleGestureDetector(
        onTap: () => controller.flipController.flip(),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(3.0, 6.0),
                blurRadius: 10.0)
          ]),
          child: AspectRatio(
            aspectRatio: cardAspectRatio,
            child: Flip(
              controller: controller.flipController,
              flipDirection: Axis.vertical,
              flipDuration: Duration(milliseconds: 200),
              secondChild: Stack(
                  children: [buildBackCardContent(delta: delta), favoriteIcon]),
              firstChild: Stack(children: [frontCardContent, favoriteIcon]),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackCardContent({double delta = 0.0}) {
    // Top hanzi part
    var partHanZi = SimpleGestureDetector(
      onTap: controller.playWord,
      child: Center(
        child:
            Table(defaultColumnWidth: IntrinsicColumnWidth(), children: [
          TableRow(
              children: word.pinyin
                  .map((e) => Center(
                        child: Text(e, style: ReviewWordsTheme.wordCardPinyin),
                      ))
                  .toList()),
          TableRow(
              children: word.word
                  .map((e) => Center(
                        child: Text(e, style: ReviewWordsTheme.wordCardWord),
                      ))
                  .toList()),
        ]),
      ),
    );
    // Second meaning part
    var partMeanings = word.wordMeanings.map((meaning) {
      var partExample = meaning.examples
          .map((wordExample) => _buildExampleRow(wordExample))
          .toList();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: partExample,
      );
    }).toList();
    return Column(
      children: <Widget>[
        Expanded(child: partHanZi, flex: 2),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: partMeanings,
          ),
          flex: 3,
        ),
      ],
    ).backgroundColor(ReviewWordsTheme.lightBlue);
  }

  Widget _buildExampleRow(WordExample wordExample) {
    return Column(
      children: [
        Text(
          'Example'.i18n,
          style: ReviewWordsTheme.wordCardSubTitle,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: SimpleGestureDetector(
                  onTap: () => controller.playExample(
                      string: wordExample.example,
                      audio: wordExample.audioMale),
                  child: RichText(
                    text: TextSpan(
                        style: ReviewWordsTheme.wordCardExample,
                        children: _divideExample([
                          word.wordAsString,
                          ...word.relatedWords
                              .map((word) => word.wordAsString)
                              .toList()
                        ], wordExample.example)
                            .map((part) => _buildExampleTextSpan(part))
                            .toList()),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
            children:[
                Text(wordExample.meaning, style: ReviewWordsTheme.exampleMeaning).paddingOnly(left: 10)
            ]
        ),
        divider()
      ],
    );
  }

  TextSpan _buildExampleTextSpan(String part) {
    // If the word is our main word
    if (part == word.wordAsString) {
      return TextSpan(
          text: part, style: TextStyle(fontWeight: FontWeight.bold));
    }
    // If the word is a related word
    var relatedWord =
        word.relatedWords.filter((word) => word.wordAsString == part);
    if (relatedWord.isNotEmpty) {
      return TextSpan(
          text: part,
          recognizer: TapGestureRecognizer()
            ..onTap = () => controller.showSingleCard(relatedWord.single),
          style: TextStyle(decoration: TextDecoration.underline));
    }
    // Default
    return TextSpan(
      text: part,
    );
  }

  Widget divider() => Divider(
        thickness: 1,
        height: 30.0,
        indent: 20,
        endIndent: 20,
        color: ReviewWordsTheme.lightYellow,
      );
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

//TODO: need to calculate width properly, we might have words of 3~4 hanzi
Map<int, TableColumnWidth> calculateColumnWidthOfHanzi(Word word) {
  const HANZI_WIDTH = 50.0;
  const PINYIN_WIDTH = 40.0;
  return word.word.asMap().map((key, value) => MapEntry(
      key,
      FixedColumnWidth(
          max(HANZI_WIDTH, word.pinyin[key].length * PINYIN_WIDTH))));
}
