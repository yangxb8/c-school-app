// 🐦 Flutter imports:
// 🌎 Project imports:

// 🌎 Project imports:

// 📦 Package imports:
import 'package:collection/collection.dart';
// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import '../core/theme/review_words_theme.dart';
import '../core/values/icons/c_school_icons.dart';
import '../data/model/word/word.dart';
import '../data/model/word/word_example.dart';
import 'blurhash_image_with_fallback.dart';
import 'controller/word_card_controller.dart';
import 'flippable_box.dart';
import 'pinyin_annotated_paragraph.dart';
import 'selectable_autosize_text.dart';

final cardAspectRatio = 12.0 / 22.0;
final icon_size = 40.0;
final verticalInset = 8.0;

class WordCard extends StatelessWidget {
  WordCard(
      {Key? key, required this.word, this.loadImage = true, isDialog = false})
      : controller = isDialog
            ? WordCardController(word)
            : Get.put<WordCardController>(WordCardController(word),
                tag: word.wordId),
        super(key: key);

  final WordCardController controller;

  /// Whether we should load the image
  final bool loadImage;

  final Word word;

  Widget buildBackCardContent() {
    // Top hanzi part
    final hanziAudioKey = Uuid().v1();
    var partHanZi = Row(
      children: [
        IconButton(
          padding: const EdgeInsets.only(top: 50),
          icon: ObxValue(
              (dynamic audioKey) => Icon(
                    CSchool.volume,
                    color: audioKey.value == hanziAudioKey
                        ? ReviewWordsTheme.lightYellow
                        : Colors.grey,
                  ),
              controller.audioService.clientKey),
          onPressed: () => controller.playWord(audioKey: hanziAudioKey),
          iconSize: icon_size,
        ),
        PinyinAnnotatedParagraph(
          paragraph: word.wordAsString,
          pinyins: word.pinyin!,
          maxLines: 1,
          defaultTextStyle: ReviewWordsTheme.wordCardWord,
          pinyinTextStyle: ReviewWordsTheme.wordCardPinyin,
        ).paddingOnly(right: 30).center().expanded()
      ],
    ).paddingOnly(top: 40).center();
    // explanation part
    var partExplanation = word.explanation!.isEmpty
        ? SizedBox.shrink()
        : SelectableAutoSizeText.unselectable(
            '💡 ${word.explanation}',
            maxLines: 5,
            style: ReviewWordsTheme.wordCardExplanation,
          ).paddingAll(10).decorated(
            borderRadius: BorderRadius.circular(10),
            color: ReviewWordsTheme.extremeLightBlue);
    // meaning part
    var partMeanings = word.wordMeanings!.map((meaning) {
      var examples = meaning.examples!
          .mapIndexed((index, wordExample) => _buildExampleRow(
              wordExample, index == meaning.examples!.length - 1))
          .toList();
      var mainPart = examples.isEmpty
          ? SizedBox.shrink()
          : Column(children: examples).paddingSymmetric(vertical: 10).decorated(
              borderRadius: BorderRadius.circular(10),
              color: ReviewWordsTheme.extremeLightBlue);
      return mainPart;
    }).toList();
    return Column(
      children: <Widget>[
        Expanded(flex: 2, child: partHanZi),
        Expanded(
          flex: 4,
          child: ListView(
            shrinkWrap: true,
            children: [partExplanation, divider(), ...partMeanings],
          ),
        ),
      ],
    )
        .paddingSymmetric(horizontal: 10)
        .backgroundColor(ReviewWordsTheme.lightBlue);
  }

  Widget _buildExampleRow(WordExample wordExample, bool isLastRow) {
    final audioKey = Uuid().v1();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                padding: const EdgeInsets.only(right: 2, top: 24),
                icon: ObxValue(
                    (dynamic key) => Icon(
                          CSchool.volume,
                          color: key.value == audioKey
                              ? ReviewWordsTheme.lightYellow
                              : Colors.grey,
                          size: icon_size,
                        ),
                    controller.audioService.clientKey),
                onPressed: () => controller.playExample(
                    wordExample: wordExample, audioKey: audioKey)),
            PinyinAnnotatedParagraph(
              paragraph: wordExample.example!,
              pinyins: wordExample.pinyin!,
              defaultTextStyle: ReviewWordsTheme.wordCardExample,
              pinyinTextStyle: ReviewWordsTheme.wordCardExamplePinyin,
              centerWord: word,
              linkedWords: word.relatedWords,
              linkedWordTextStyle: ReviewWordsTheme.wordCardExampleLinkedWord,
              spacing: 2,
            ).expanded()
          ],
        ),
        SelectableAutoSizeText.unselectable(
          wordExample.meaning!,
          style: ReviewWordsTheme.exampleMeaning,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 50),
        isLastRow ? const SizedBox.shrink() : Divider()
      ],
    );
  }

  Widget divider() => const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final emptyImage = Container(
      decoration: BoxDecoration(
        color: ReviewWordsTheme.lightBlue,
        border: Border.all(color: ReviewWordsTheme.lightBlue, width: 0),
      ),
    );
    var frontCardContent = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...word.wordMeanings!
                    .map((e) => SelectableAutoSizeText.unselectable(
                          e.meaning!,
                          style: ReviewWordsTheme.wordCardMeaning,
                          maxLines: 1,
                        ).paddingSymmetric(vertical: 10))
                    .toList(),
              ],
            ).backgroundColor(ReviewWordsTheme.lightBlue).expanded(),
          ],
        ).expanded(),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: loadImage
              ? BlurHashImageWithFallback(
                  fallbackImg: emptyImage,
                  mainImgUrl: word.pic?.url,
                  blurHash: word.picHash!)
              : emptyImage,
        )
      ],
    );
    var favoriteIcon = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => IconButton(
            padding: EdgeInsets.only(top: 15, right: 15),
            splashRadius: 0.01,
            icon: Icon(CSchool.heart),
            // key: favoriteButtonKey,
            color: controller.isWordLiked()
                ? ReviewWordsTheme.lightYellow
                : Colors.grey,
            iconSize: icon_size * 0.9,
            onPressed: () => controller.toggleFavoriteCard(),
          ),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: SimpleGestureDetector(
          onDoubleTap: controller.flipCard,
          child: Obx(
            () => FlippableBox(
              duration: 0.3,
              isFlipped: controller.isCardFlipped.value,
              curve: Curves.easeOut,
              back: Container(
                  constraints: BoxConstraints.expand(),
                  child:
                      Stack(children: [buildBackCardContent(), favoriteIcon])),
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
}
