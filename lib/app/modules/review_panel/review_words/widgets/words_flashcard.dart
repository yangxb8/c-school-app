// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import '../../../../core/utils/index.dart';
import '../../../../core/values/icons/c_school_icons.dart';
import '../../../../data/model/word/word.dart';
import '../../../../core/service/logger_service.dart';
import '../../../../global_widgets/word_card/word_card.dart';
import '../review_words_detail_controller.dart';

// 🌎 Project imports:

const BUTTON_SIZE = 50.0;
const cardAspectRatio = 12.0 / 22.0;
const widgetAspectRatio = cardAspectRatio * 1.2;

class WordsFlashcard extends GetView<ReviewWordsController> {
  WordsFlashcard({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.pageController.addListener(() {
      controller.pageFraction.value = controller.pageController.page!;
    });

    Future<void> _onHorizontalSwipe(swipeDirection) async {
      // If in autoPlay mode, disable swipe
      if (controller.isAutoPlayMode.value) return;
      if (swipeDirection == SwipeDirection.right) {
        await controller.previousCard();
      } else {
        await controller.nextCard();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: SimpleGestureDetector(
        onHorizontalSwipe: _onHorizontalSwipe,
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                // We only use this to control the controller.pageController behind screen
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: controller.reversedWordsList.length,
                    controller: controller.pageController,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
                ),
                Obx(() => CardScrollWidget(controller.pageFraction.value)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  padding: EdgeInsets.only(top: 4),
                  splashRadius: 0.01,
                  icon: Obx(
                    () => Icon(
                      CSchool.correct,
                      color: controller.wordMemoryStatus.value ==
                              WordMemoryStatus.REMEMBERED
                          ? Colors.redAccent
                          : Colors.grey,
                      size: BUTTON_SIZE,
                    ),
                  ),
                  onPressed: () => controller
                      .handWordMemoryStatusPressed(WordMemoryStatus.REMEMBERED),
                ),
                IconButton(
                  splashRadius: 0.01,
                  icon: Obx(
                    () => Icon(
                      CSchool.wrong,
                      color: controller.wordMemoryStatus.value ==
                              WordMemoryStatus.FORGOT
                          ? Colors.blueAccent
                          : Colors.grey,
                      size: BUTTON_SIZE,
                    ),
                  ),
                  onPressed: () => controller
                      .handWordMemoryStatusPressed(WordMemoryStatus.FORGOT),
                ).paddingOnly(bottom: 12),
              ],
            ).paddingOnly(right: 20)
          ],
        ),
      ),
    );
  }
}

class CardScrollWidget extends GetView<ReviewWordsController> {
  CardScrollWidget(this.pageFraction);

  static const MAX_CARDS_FRAME = 4;

  final logger = LoggerService.logger;
  final padding = 10.0;
  final pageFraction;
  final verticalInset = 8.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, constraints) {
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;

        var safeWidth = width - 4 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 4;

        var cardList = <Widget>[];

        for (var i = 0; i < controller.reversedWordsList.length; i++) {
          var delta = i - pageFraction;
          var isPrimaryCard = delta >= 0 && delta.toInt() == 0;
          // If card is not visible, don't build it
          if (delta > 1 || -delta > MAX_CARDS_FRAME) {
            continue;
          }
          var isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 40 : 1),
                  0.0);
          var wordCard = WordCard(
              // Key was added to prevent strange behavior of card flip status
              key: ValueKey(controller.reversedWordsList[i]),
              word: controller.reversedWordsList[i],
              loadImage: delta.abs() < 2);
          // Set primary card controller
          if (isPrimaryCard) {
            controller.primaryWordIndex.value = i;
            controller.primaryWordCardController = wordCard.controller;
          }
          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: wordCard,
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    ).afterFirstLayout(controller.afterFirstLayout);
  }
}
