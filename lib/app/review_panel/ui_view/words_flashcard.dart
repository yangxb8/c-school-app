import 'package:flutter/material.dart';
import 'package:flip/flip.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:spoken_chinese/controller/review_words_controller.dart';
import 'package:spoken_chinese/service/logger_service.dart';
import 'dart:math';

//TODO: this is test data
List<String> images = [
  "assets/review_panel/image_04.jpg",
  "assets/review_panel/image_03.jpg",
  "assets/review_panel/image_02.jpg",
  "assets/review_panel/image_01.png",
  "assets/review_panel/image_04.jpg",
  "assets/review_panel/image_03.jpg",
  "assets/review_panel/image_02.jpg",
  "assets/review_panel/image_01.png",
];

List<String> title = [
  "Hounted Ground",
  "Fallen In Love",
  "The Dreaming Moon",
  "Jack the Persian and the Black Castel",
  "Hounted Ground",
  "Fallen In Love",
  "The Dreaming Moon",
  "Jack the Persian and the Black Castel",
];

class WordsFlashcard extends StatefulWidget {
  @override
  _WordsFlashcardState createState() => _WordsFlashcardState();
}

var cardAspectRatio = 12.0 / 22.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _WordsFlashcardState extends State<WordsFlashcard> {
  final ReviewWordsController reviewWordsController = Get.find();
  var pageFraction = images.length - 1.0;
  var flipController = FlipController();

  @override
  Widget build(BuildContext context) {
    var controller = PageController(initialPage: images.length - 1);
    controller.addListener(() {
      setState(() {
        pageFraction = controller.page;
        if(!flipController.isFront) flipController.flip();
      });
    });

    void _onTap() => flipController.flip();

    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
      child: SimpleGestureDetector(
        onTap: _onTap,
        child: Stack(
          children: <Widget>[
            CardScrollWidget(pageFraction, flipController),
            Positioned.fill(
              child: PageView.builder(
                itemCount: images.length,
                controller: controller,
                reverse: true,
                itemBuilder: (context, index) {
                  return Container();
                },
              ),
            ),
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
  final verticalInset = 10.0;
  final logger = Get.find<LoggerService>().logger;

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

        for (var i = 0; i < images.length; i++) {
          var delta = i - pageFraction;
          var isPrimaryCard = delta.toInt() == 0;
          var isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 40 : 1),
                  0.0);

          var _cardContent = Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(images[i], fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(title[i],
                          style:
                              TextStyle(color: Colors.white, fontSize: 25.0)),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Text('Read Later',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
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
                  child: isPrimaryCard
                      ? Flip(
                          controller: flipController,
                          flipDirection: Axis.horizontal,
                          flipDuration: Duration(milliseconds: 200),
                          secondChild: Center(child: Text('Back')),
                          firstChild: _cardContent,
                        )
                      : _cardContent,
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
}

extension ShouldFlip on FlipController {
  void flipIf(bool shouldFlip) {
    if (shouldFlip) flip();
  }
}
