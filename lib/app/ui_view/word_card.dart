// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flippable_box/flippable_box.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/word_example.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/app/ui_view/blurhash_image_with_fallback.dart';
import 'package:c_school_app/app/ui_view/pinyin_annotated_paragraph.dart';
import '../../c_school_icons.dart';
import '../model/word.dart';
import 'controller/word_card_controller.dart';

final cardAspectRatio = 12.0 / 22.0;
final icon_size = 30.0;
final verticalInset = 8.0;

class WordCard extends StatelessWidget {
  final Word word;

  /// Whether we should load the image
  final bool loadImage;
  final WordCardController controller;
  WordCard({Key key, @required this.word, this.loadImage = true})
      : controller = Get.put<WordCardController>(WordCardController(word), tag: word.wordId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    ;
    final emptyImage = Container(
      color: ReviewWordsTheme.lightBlue,
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
                            ).paddingSymmetric(vertical: 10))
                        .toList(),
                  ],
                ).expanded(),
              ],
            ).backgroundColor(ReviewWordsTheme.lightBlue),
            flex: 11),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: loadImage
              ? [
                  BlurHashImageWithFallback(
                          fallbackImg: emptyImage,
                          mainImgUrl: word.pic?.url,
                          blurHash: word.picHash)
                      .expanded()
                ]
              : [emptyImage.expanded()],
        ).expanded(flex: 10)
      ],
    );
    var favoriteIcon = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => IconButton(
            splashRadius: 0.01,
            icon: Icon(CSchool.heart),
            // key: favoriteButtonKey,
            color: controller.isWordLiked() ? ReviewWordsTheme.lightYellow : Colors.grey,
            iconSize: icon_size * 1.7,
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
              duration: 0.3,
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
    final hanziAudioKey = Uuid().v1();
    var partHanZi = Row(
      children: [
        IconButton(
          padding: const EdgeInsets.all(0),
          icon: ObxValue(
              (audioKey) => Icon(
                    CSchool.volume,
                    color: audioKey.value == hanziAudioKey ? Colors.lightBlueAccent : Colors.grey,
                  ),
              controller.audioService.clientKey),
          onPressed: () => controller.playWord(audioKey: hanziAudioKey),
          iconSize: icon_size,
        ),
        PinyinAnnotatedParagraph(
          paragraph: word.wordAsString,
          pinyins: word.pinyin,
          maxLines: 1,
          defaultTextStyle: ReviewWordsTheme.wordCardWord,
          pinyinTextStyle: ReviewWordsTheme.wordCardPinyin,
        ).paddingOnly(right: 30).center().expanded()
      ],
    ).paddingOnly(top: 30).center();
    // explanation part
    var partExplanation = word.explanation.isEmpty
        ? SizedBox.shrink()
        : AutoSizeText(
            '💡 ${word.explanation}',
            maxLines: 5,
            style: ReviewWordsTheme.wordCardExplanation,
          ).decorated(
            borderRadius: BorderRadius.circular(10), color: ReviewWordsTheme.extremeLightBlue);
    // meaning part
    var partMeanings = word.wordMeanings.map((meaning) {
      var examples = meaning.examples
          .map((wordExample) => _buildExampleRow(wordExample))
          .toList();
      var mainPart = examples.isEmpty
          ? SizedBox.shrink()
          : Column(children: examples).decorated(
              borderRadius: BorderRadius.circular(10), color: ReviewWordsTheme.extremeLightBlue);
      return mainPart;
    }).toList();
    return Column(
      children: <Widget>[
        Expanded(child: partHanZi, flex: 2),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [partExplanation, divider(), ...partMeanings],
          ),
          flex: 4,
        ),
      ],
    ).paddingSymmetric(horizontal: 10).backgroundColor(ReviewWordsTheme.lightBlue);
  }

  Widget _buildExampleRow(WordExample wordExample) {
    final audioKey = Uuid().v1();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                padding: const EdgeInsets.only(right: 2,top:15),
                icon: ObxValue(
                    (key) => Icon(
                          CSchool.volume,
                          color: key.value == audioKey ? Colors.lightBlueAccent : Colors.grey,
                          size: icon_size,
                        ),
                    controller.audioService.clientKey),
                onPressed: () =>
                    controller.playExample(wordExample: wordExample, audioKey: audioKey)),
            PinyinAnnotatedParagraph(
              paragraph: wordExample.example,
              pinyins: wordExample.pinyin,
              defaultTextStyle: ReviewWordsTheme.wordCardExample,
              pinyinTextStyle: ReviewWordsTheme.wordCardExamplePinyin,
              centerWord: word,
              linkedWords: word.relatedWords,
              linkedWordTextStyle: ReviewWordsTheme.wordCardExampleLinkedWord,
              spacing: 2,
            ).expanded()
          ],
        ),
        AutoSizeText(
          wordExample.meaning,
          style: ReviewWordsTheme.exampleMeaning,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 50),
        divider()
      ],
    );
  }

  Widget divider() => SizedBox(height: 20);
}

bool isMainExample(String example) => example.startsWith('*');
