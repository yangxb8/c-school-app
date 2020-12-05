import 'package:c_school_app/app/ui_view/word_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:c_school_app/service/logger_service.dart';
import 'dart:math';

const BUTTON_SIZE = 50.0;
const cardAspectRatio = 12.0 / 22.0;
const widgetAspectRatio = cardAspectRatio * 1.2;

class WordsFlashcard extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    controller.pageController.addListener(() {
      controller.pageFraction.value = controller.pageController.page;
      controller.flipBackPrimaryCard();
    });

    Future<void> _onHorizontalSwipe(swipeDirection) async {
      var currentPrimaryWord = controller.primaryWord;
      if (swipeDirection == SwipeDirection.right) {
        await controller.pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        await controller.pageController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
      if (!controller.isFirstPage && !controller.isLastPage) {
        controller.saveAndResetWordHistory(currentPrimaryWord);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: SimpleGestureDetector(
        onHorizontalSwipe: _onHorizontalSwipe,
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                // We only use this to control the controller.pageController behind screen
                Positioned.fill(
                  child: PageView.builder(
                    onPageChanged: controller.notifyPageChanged,
                    itemCount: controller.wordsList.length,
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
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    splashRadius: 0.01,
                    icon: Obx(
                      () => FaIcon(
                        FontAwesomeIcons.laughBeam,
                        color: controller.wordMemoryStatus.value ==
                                WordMemoryStatus.REMEMBERED
                            ? Colors.yellowAccent
                            : Colors.blueGrey,
                        size: BUTTON_SIZE,
                      ),
                    ),
                    onPressed: () => controller.handWordMemoryStatusPressed(
                        WordMemoryStatus.REMEMBERED),
                  ),
                  IconButton(
                    splashRadius: 0.01,
                    icon: Obx(
                      () => FaIcon(
                        FontAwesomeIcons.frownOpen,
                        color: controller.wordMemoryStatus.value ==
                                WordMemoryStatus.NORMAL
                            ? Colors.yellowAccent
                            : Colors.blueGrey,
                        size: BUTTON_SIZE,
                      ),
                    ),
                    onPressed: () => controller
                        .handWordMemoryStatusPressed(WordMemoryStatus.NORMAL),
                  ),
                  IconButton(
                    splashRadius: 0.01,
                    icon: Obx(
                      () => FaIcon(
                        FontAwesomeIcons.sadCry,
                        color: controller.wordMemoryStatus.value ==
                                WordMemoryStatus.FORGOT
                            ? Colors.yellowAccent
                            : Colors.blueGrey,
                        size: BUTTON_SIZE,
                      ),
                    ),
                    onPressed: () => controller
                        .handWordMemoryStatusPressed(WordMemoryStatus.FORGOT),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CardScrollWidget extends GetView<ReviewWordsController> {
  final pageFraction;
  final padding = 10.0;
  final verticalInset = 8.0;
  final logger = Get.find<LoggerService>().logger;
  static const MAX_CARDS_FRAME = 8;

  CardScrollWidget(this.pageFraction);

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

        for (var i = 0; i < controller.wordsList.length; i++) {
          var delta = i - pageFraction;
          var isPrimaryCard = delta.toInt() == 0;
          // If card is not visible, don't build it
          if (delta.abs() > MAX_CARDS_FRAME) {
            continue;
          }
          if (isPrimaryCard) {
            controller.primaryWordOrdinal.value = i;
          }
          var isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 40 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: WordCard(word: controller.wordsList[i], delta: delta),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }
}
