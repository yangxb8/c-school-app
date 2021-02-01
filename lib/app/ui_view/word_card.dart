// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flippable_box/flippable_box.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/word_example.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/app/ui_view/blurhash_image_with_fallback.dart';
import 'package:c_school_app/app/ui_view/pinyin_annotated_paragraph.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import '../model/word.dart';

final cardAspectRatio = 12.0 / 22.0;
final BUTTON_SIZE = 25.0;
final verticalInset = 8.0;
final DEFAULT_IMAGE = 'assets/review_panel/default.png';

class WordCard extends StatelessWidget {
  final Word word;

  /// Whether we should load the image
  final bool loadImage;
  final WordCardController controller;
  WordCard({Key key, @required this.word, this.loadImage})
      : controller = Get.put<WordCardController>(WordCardController(word), tag: word.wordId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var hint = SimpleGestureDetector(
      onTap: controller.toggleHint,
      child: CircleAvatar(
        radius: 20,
        child: Obx(
          () => SimpleTooltip(
            tooltipTap: controller.toggleHint,
            tooltipDirection: TooltipDirection.down,
            borderColor: Colors.transparent,
            show: controller.isHintShown.value,
            ballonPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            maxWidth: Get.width * 0.7,
            content: AutoSizeText(
              word.hint,
              style: ReviewWordsTheme.wordCardHint,
              maxLines: 1,
            ),
            child: Icon(FontAwesome5.lightbulb,
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
                        .map((e) => AutoSizeText(
                              e.meaning,
                              style: ReviewWordsTheme.wordCardMeaning,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                            ).paddingSymmetric(vertical: 10))
                        .toList(),
                    if (!word.hint.isBlank) hint else Container()
                  ],
                ),
              ],
            ).backgroundColor(ReviewWordsTheme.lightBlue),
            flex: 11),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: loadImage
              ? [
                  BlurHashImageWithFallback(
                          fallbackImg: DEFAULT_IMAGE,
                          mainImg: word.pic?.url,
                          blurHash: word.picHash)
                      .expanded()
                ]
              : [
                  Container(
                    color: Colors.white70,
                  ).expanded()
                ],
        ).expanded(flex: 10)
      ],
    );
    var favoriteIcon = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => IconButton(
            splashRadius: 0.01,
            icon: Icon(FontAwesome.heart),
            // key: favoriteButtonKey,
            color: controller.isWordLiked() ? ReviewWordsTheme.lightYellow : Colors.grey,
            iconSize: BUTTON_SIZE * 2,
            onPressed: () => controller.toggleFavoriteCard(),
          ).paddingOnly(top: 10, right: 10),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: SimpleGestureDetector(
          onTap: controller.flipCard,
          child: Obx(
            () => FlippableBox(
              isFlipped: controller.isCardFlipped.value,
              curve: Curves.easeOut,
              back: Container(
                  constraints: BoxConstraints.expand(),
                  child: Stack(children: [buildBackCardContent(), favoriteIcon])),
              front: Container(
                  constraints: BoxConstraints.expand(),
                  child: Stack(children: [frontCardContent, favoriteIcon])),
            ),
          ),
        ),
      ),
    ).card(
      color: Colors.transparent,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  Widget buildBackCardContent() {
    // Top hanzi part
    var partHanZi = SimpleGestureDetector(
      onTap: controller.playWord,
      behavior: HitTestBehavior.opaque,
      child: PinyinAnnotatedParagraph(
        paragraph: word.wordAsString,
        pinyins: word.pinyin,
        defaultTextStyle: ReviewWordsTheme.wordCardWord,
        pinyinTextStyle: ReviewWordsTheme.wordCardPinyin,
      ),
    ).center();
    // Second meaning part
    var partMeanings = word.wordMeanings.map((meaning) {
      var partExample =
          meaning.examples.map((wordExample) => _buildExampleRow(wordExample)).toList();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: partExample,
      );
    }).toList();
    // explanation part
    var partExplanation = word.explanation.isEmpty
        ? SizedBox.shrink()
        : AutoSizeText(
            '💡 ${word.explanation}',
            maxLines: 5,
            style: ReviewWordsTheme.wordCardExplanation,
          )
            .paddingAll(10)
            .decorated(
                borderRadius: BorderRadius.circular(5), color: ReviewWordsTheme.extremeLightBlue)
            .paddingSymmetric(horizontal: 20, vertical: 40);
    return Column(
      children: <Widget>[
        Expanded(child: partHanZi, flex: 2),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [partExplanation, ...partMeanings],
          ),
          flex: 3,
        ),
      ],
    ).backgroundColor(ReviewWordsTheme.lightBlue);
  }

  Widget _buildExampleRow(WordExample wordExample) {
    return Column(
      children: [
        SimpleGestureDetector(
          onTap: () => controller.playExample(wordExample: wordExample),
          behavior: HitTestBehavior.opaque,
          child: PinyinAnnotatedParagraph(
            paragraph: wordExample.example,
            pinyins: wordExample.pinyin,
            defaultTextStyle: ReviewWordsTheme.wordCardExample,
            pinyinTextStyle: ReviewWordsTheme.wordCardExamplePinyin,
            centerWord: word,
            centerWordTextStyle: ReviewWordsTheme.wordCardExampleCenterWord,
            linkedWords: word.relatedWords,
            linkedWordTextStyle: ReviewWordsTheme.wordCardExampleLinkedWord,
          ).alignment(Alignment.centerLeft).paddingSymmetric(horizontal: 20),
        ),
        AutoSizeText(
          wordExample.meaning,
          style: ReviewWordsTheme.exampleMeaning,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 20),
        divider()
      ],
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
