import 'package:flutter/material.dart';
import 'package:flip/flip.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:spoken_chinese/util/functions.dart';
import 'package:supercharged/supercharged.dart';
import 'package:spoken_chinese/app/review_panel/controller/review_words_controller.dart';
import 'package:spoken_chinese/service/logger_service.dart';
import 'dart:math';

const BUTTON_SIZE = 50.0;

class WordsFlashcard extends StatefulWidget {
  @override
  _WordsFlashcardState createState() => _WordsFlashcardState();
}

var cardAspectRatio = 12.0 / 22.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _WordsFlashcardState extends State<WordsFlashcard> {
  final ReviewWordsController reviewWordsController = Get.find();
  var pageFraction;
  var flipController = FlipController();

  @override
  void initState() {
    pageFraction = reviewWordsController.wordsList.length - 1.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pageController =
        PageController(initialPage: reviewWordsController.wordsList.length - 1);
    pageController.addListener(() {
      setState(() {
        pageFraction = pageController.page;
        if (!flipController.isFront) flipController.flip();
      });
    });

    void _onTap() {
      flipController.flip();
    }

    void _onHorizontalSwipe(swipeDirection) {
      if (swipeDirection == SwipeDirection.right) {
        pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        pageController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
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
                // We only use this to control the PageController behind screen
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: reviewWordsController.wordsList.length,
                    controller: pageController,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
                ),
                CardScrollWidget(pageFraction, flipController),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  LikeButton(
                      size: BUTTON_SIZE,
                      likeCount: 665,
                      circleColor: CircleColor(
                          start: Color(0xff00ddff), end: Color(0xff0099cc)),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Color(0xff33b5e5),
                        dotSecondaryColor: Color(0xff0099cc),
                      ),
                      likeBuilder: (bool isLiked) {
                        return FaIcon(
                          FontAwesomeIcons.laughSquint,
                          color:
                              isLiked ? Colors.lightGreenAccent : Colors.grey,
                          size: BUTTON_SIZE,
                        );
                      }),
                  LikeButton(
                      size: BUTTON_SIZE,
                      likeCount: 665,
                      likeBuilder: (bool isLiked) {
                        return FaIcon(
                          FontAwesomeIcons.tired,
                          color: isLiked ? Colors.redAccent : Colors.grey,
                          size: BUTTON_SIZE,
                        );
                      })
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
  final double pageFraction;
  final flipController;
  final padding = 10.0;
  final verticalInset = 8.0;
  final logger = Get.find<LoggerService>().logger;
  static const MAX_CARDS_FRAME = 8;

  CardScrollWidget(this.pageFraction, this.flipController);

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
                              controller: flipController,
                              flipDirection: Axis.vertical,
                              flipDuration: Duration(milliseconds: 200),
                              secondChild: buildBackCardContent(i, delta),
                              firstChild: buildFrontCardContent(i),
                            )
                          : buildFrontCardContent(i),
                      isPrimaryCard
                          ? Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.favorite),
                                    // key: favoriteButtonKey,
                                    color: controller.isFavorite
                                        ? Colors.redAccent
                                        : Colors.grey,
                                    iconSize: BUTTON_SIZE,
                                    onPressed: () =>
                                        controller.toggleFavorite(),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
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
                                  onTap: () => controller.playExample(string: exampleAndAudio.key, audio: exampleAndAudio.value),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black),
                                            //TODO: give related words a link
                                        children: _divideExample([
                                          controller.primaryWordString,
                                          ...controller.primaryWord.relatedWords.map((word)=>word.word.join()).toList()
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
