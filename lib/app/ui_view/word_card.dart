import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flamingo/src/model/storage_file.dart';
import 'package:flip/flip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import '../../util/functions.dart';
import '../models/word.dart';

const cardAspectRatio = 12.0 / 22.0;
const BUTTON_SIZE = 50.0;
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
    var frontCardContent = Center(
        child: SimpleGestureDetector(
      onTap: controller.playMeanings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: word.wordMeanings
            .map((e) => Text(
                  e.meaning,
                  style: TextStyle(fontSize: 40.0),
                ))
            .toList(),
      ),
    ));
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
            child: Stack(
              children: [
                Flip(
                  controller: controller.flipController,
                  flipDirection: Axis.vertical,
                  flipDuration: Duration(milliseconds: 200),
                  secondChild: buildBackCardContent(delta: delta),
                  firstChild: frontCardContent,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => IconButton(
                        splashRadius: 0.01,
                        icon: Icon(Icons.favorite),
                        // key: favoriteButtonKey,
                        color: controller.isWordLiked()
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
      ),
    );
  }

  Widget buildBackCardContent({double delta = 0.0}) {
    // Top hanzi part
    var partHanZi = <Widget>[
      ListTile(
        title: SimpleGestureDetector(
          onTap: controller.playWord,
          child: Center(
            child: Table(
                columnWidths: calculateColumnWidthOfHanzi(word),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              '・${meaning.meaning}：',
                              style: TextStyle(fontSize: 30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] +
                  meaning.exampleAndAudios.entries
                      .map((exampleAndAudio) =>
                          _buildExampleRow(exampleAndAudio))
                      .toList(),
            ))
        .toList();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 200 + verticalInset * delta * 2,
          width: double.infinity,
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
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [...partHanZi, ...partMeanings, divider()],
          ),
        ),
      ],
    );
  }

  Row _buildExampleRow(MapEntry<String, StorageFile> exampleAndAudio) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 20),
            child: SimpleGestureDetector(
              onTap: () => controller.playExample(
                  string: exampleAndAudio.key, audio: exampleAndAudio.value),
              child: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                    //TODO: give related words a link
                    children: _divideExample([
                      word.wordAsString,
                      ...word.relatedWords
                          .map((word) => word.word.join())
                          .toList()
                    ], exampleAndAudio.key)
                        .map((part) => _buildExampleTextSpan(part))
                        .toList()),
              ),
            ),
          ),
        ),
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
          style: TextStyle(
              decoration: TextDecoration.underline));
    }
    // Default
    return TextSpan(
      text: part,
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
