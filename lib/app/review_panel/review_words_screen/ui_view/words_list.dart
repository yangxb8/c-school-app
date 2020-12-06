import 'package:c_school_app/app/models/word.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';

class WordsList extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: StickyGroupedListView<Word, String>(
        elements: controller.wordsList,
        floatingHeader: true,
        groupBy: (Word element) => element.cschoolClass.classId,
        groupSeparatorBuilder: (Word element) =>
            Text(element.cschoolClass.title)
                .paddingAll(10.0)
                .decorated(
                  color: Colors.blue[300],
                  border: Border.all(
                    color: Colors.blue[300],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                )
                .paddingOnly(top: 10.0, bottom: 10.0),
        itemBuilder: (_, Word word) => FadeInRight(
          duration: 0.5.seconds,
          delay: (0.3 * controller.calculateWordIndex(word)).seconds,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: SimpleGestureDetector(
              onTap: () => controller.showSingleCard(word),
              child: ListTile(
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.play),
                    onPressed: () => controller.playWord(word: word),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      Text('${word.wordAsString}       '),
                      Text(word.pinyin.join(' '))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        itemComparator: (element1, element2) =>
            element1.wordId.compareTo(element2.wordId),
        // optional
        itemScrollController: GroupedItemScrollController(),
        // optional
        order: StickyGroupedListOrder.ASC, // optional
      ),
    );
  }
}
