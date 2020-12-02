import 'package:flutter/material.dart';
import 'package:flip/flip.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/util/functions.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:supercharged/supercharged.dart';
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
      if (!controller.flipController.isFront) controller.flipController.flip();
    });

    void _onTap() {
      controller.flipController.flip();
    }

    Future<void> _onHorizontalSwipe(swipeDirection) async {
      var currentPrimaryWord = controller.primaryWord;
      if (swipeDirection == SwipeDirection.right) {
        await controller.pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        await controller.pageController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
      controller.saveAndResetWordHistory(currentPrimaryWord);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: SimpleGestureDetector(
        onTap: _onTap,
        onHorizontalSwipe: _onHorizontalSwipe,
        child: Column(
            children: [
              Stack(
                children: <Widget>[
                  // We only use this to control the controller.pageController behind screen
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: controller.wordsList.length,
                      controller: controller.pageController,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container();
                      },
                    ),
                  ),
                  Obx(()=> CardScrollWidget(controller.pageFraction.value)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        splashRadius: 0.01,
                        icon: Obx(()=>
                          FaIcon(
                                  FontAwesomeIcons.laughBeam,
                                  color:
                                  controller.wordMemoryStatus.value ==
                                      WordMemoryStatus.REMEMBERED ? Colors.yellowAccent : Colors.blueGrey,
                                  size: BUTTON_SIZE,
                                ),
                        ), onPressed: ()=>controller.handWordMemoryStatusPressed(WordMemoryStatus.REMEMBERED),
                      ),
                      IconButton(
                        splashRadius: 0.01,
                        icon: Obx(()=>
                          FaIcon(
                                  FontAwesomeIcons.frownOpen,
                                  color:
                                  controller.wordMemoryStatus.value ==
                                      WordMemoryStatus.NORMAL ? Colors.yellowAccent : Colors.blueGrey,
                                  size: BUTTON_SIZE,
                                ),
                        ), onPressed: ()=>controller.handWordMemoryStatusPressed(WordMemoryStatus.NORMAL),
                      ),
                      IconButton(
                        splashRadius: 0.01,
                        icon: Obx(()=>
                          FaIcon(
                                  FontAwesomeIcons.sadCry,
                                  color:
                                  controller.wordMemoryStatus.value ==
                                      WordMemoryStatus.FORGOT ? Colors.yellowAccent : Colors.blueGrey,
                                  size: BUTTON_SIZE,
                                ),
                        ), onPressed: ()=>controller.handWordMemoryStatusPressed(WordMemoryStatus.FORGOT),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    children: [
                      isPrimaryCard
                          ? Flip(
                              controller: controller.flipController,
                              flipDirection: Axis.vertical,
                              flipDuration: Duration(milliseconds: 200),
                              secondChild: buildBackCardContent(i, delta),
                              firstChild: buildFrontCardContent(i),
                            )
                          : buildFrontCardContent(i),
                      Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Obx(()=>
                                  IconButton(
                                    splashRadius: 0.01,
                                    icon: Icon(Icons.favorite),
                                    // key: favoriteButtonKey,
                                    color: controller.isWordLiked(controller.wordsList[i])
                                        ? Colors.redAccent
                                        : Colors.grey,
                                    iconSize: BUTTON_SIZE,
                                    onPressed: () =>
                                        controller.toggleFavoriteCard(i),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }

  Widget buildBackCardContent(int i, double delta) {
    // Top hanzi part
    var partHanZi = <Widget>[
      ListTile(
        title: SimpleGestureDetector(
          onTap: controller.playWord,
          child: Center(
            child: Table(
                columnWidths:
                    calculateColumnWidthOfHanzi(controller.wordsList[i]),
                children: [
                  TableRow(
                      children: controller.wordsList[i].pinyin
                          .map((e) => Center(
                                child:
                                    Text(e, style: TextStyle(fontSize: 40.0)),
                              ))
                          .toList()),
                  TableRow(
                      children: controller.wordsList[i].word
                          .map((e) => Center(
                                child:
                                    Text(e, style: TextStyle(fontSize: 40.0)),
                              ))
                          .toList()),
                ]),
          ),
        ),
      ),
      divider()
    ];
    // Second meaning part
    var partMeanings = controller.wordsList[i].wordMeanings
        .map((meaning) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            '・${meaning.meaning}：',
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ),
                      ],
                    ),
                  ] +
                  meaning.exampleAndAudios.entries
                      .map((exampleAndAudio) => Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 50.0),
                                child: SimpleGestureDetector(
                                  onTap: () => controller.playExample(
                                      string: exampleAndAudio.key,
                                      audio: exampleAndAudio.value),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black),
                                        //TODO: give related words a link
                                        children: _divideExample([
                                          controller.primaryWordString,
                                          ...controller.primaryWord.relatedWords
                                              .map((word) => word.word.join())
                                              .toList()
                                        ], exampleAndAudio.key)
                                            .map((part) => TextSpan(
                                                text: part,
                                                style: part ==
                                                        controller
                                                            .primaryWordString
                                                    ? TextStyle(
                                                        color: Colors.redAccent)
                                                    : null))
                                            .toList()),
                                  ),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
            ))
        .toList();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 200 + verticalInset * delta * 2,
          width: double.infinity,
          //TODO: Dummy image change this to word asset
          child: Image.asset('assets/review_panel/image_01.png',
              fit: BoxFit.cover),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: partHanZi + partMeanings + [divider()],
          ),
        ),
      ],
    );
  }

  Widget buildFrontCardContent(int i) => Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: controller.wordsList[i].wordMeanings
            .map((e) => Text(
                  e.meaning,
                  style: TextStyle(fontSize: 40.0),
                ))
            .toList(),
      ));

  Widget divider() => Divider(
        height: 30.0,
        indent: 30,
        endIndent: 30,
        color: Colors.lightBlueAccent,
      );

  /// Divide sentence into List of String by keyword(s)
  List<String> _divideExample(dynamic keyword, dynamic example) {
    var exampleDivided = <String>[];
    // When we have multiple keyword
    if (keyword is List<String>) {
      keyword.forEach((k) => exampleDivided.addAll(_divideExample(k, example)));
      return exampleDivided;
    }
    // When the String is already divided before
    if (example is List<String>) {
      example.forEach((e) {
        if (e.contains(keyword)) {
          exampleDivided.addAll(_divideExample(e, example));
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
}
