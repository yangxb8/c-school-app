import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:flip/flip.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import '../../util/functions.dart';
import '../models/word.dart';

const cardAspectRatio = 12.0 / 22.0;
const BUTTON_SIZE = 50.0;

class WordCard extends StatelessWidget {
  final Word word;
  final WordCardController controller;
  final FlipController flipController = FlipController();
  WordCard({@required this.word})
      : controller = Get.put(WordCardController(word));

  @override
  Widget build(BuildContext context) {
    var frontCardContent = Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: word.wordMeanings
          .map((e) => Text(
                e.meaning,
                style: TextStyle(fontSize: 40.0),
              ))
          .toList(),
    ));
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12, offset: Offset(3.0, 6.0), blurRadius: 10.0)
        ]),
        child: AspectRatio(
          aspectRatio: cardAspectRatio,
          child: Stack(
            children: [
              SimpleGestureDetector(
                onTap: () => flipController.flip(),
                child: Flip(
                  controller: flipController,
                  flipDirection: Axis.vertical,
                  flipDuration: Duration(milliseconds: 200),
                  secondChild: buildBackCardContent(),
                  firstChild: frontCardContent,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => IconButton(
                      splashRadius: 0.01,
                      icon: Icon(Icons.favorite),
                      // key: favoriteButtonKey,
                      color: controller.isWordLiked.value
                          ? Colors.redAccent
                          : Colors.grey,
                      iconSize: BUTTON_SIZE,
                      onPressed: () => controller.toggleFavoriteCard(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget buildBackCardContent() {
    // Top hanzi part
    var partHanZi = <Widget>[
      ListTile(
        title: SimpleGestureDetector(
          onTap: controller.playWord,
          child: Center(
            child: Table(
                columnWidths:
                calculateColumnWidthOfHanzi(word),
                children: [
                  TableRow(
                      children: word.pinyin
                          .map((e) => Center(
                        child:
                        Text(e, style: TextStyle(fontSize: 40.0)),
                      ))
                          .toList()),
                  TableRow(
                      children: word.word
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
    var partMeanings = word.wordMeanings
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
                          word.wordAsString,
                          ...word.relatedWords
                              .map((word) => word.word.join())
                              .toList()
                        ], exampleAndAudio.key)
                            .map((part) => TextSpan(
                            text: part,
                            style: part ==
                                word.wordAsString
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
          height: 200,
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

  Widget divider() => Divider(
    height: 30.0,
    indent: 30,
    endIndent: 30,
    color: Colors.lightBlueAccent,
  );
}

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
