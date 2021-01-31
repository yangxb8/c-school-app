import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/app/ui_view/pinyin_annotated_paragraph.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';

const BUTTON_SIZE = 50.0;

class WordsList extends GetView<ReviewWordsController> {
  WordsList({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: StickyGroupedListView<Word, String>(
          elements: controller.wordsList,
          floatingHeader: true,
          groupBy: (Word element) => element.lecture.lectureId,
          groupSeparatorBuilder: (Word element) => Text(
            element.lecture.title,
            style: ReviewWordsTheme.wordListTitle,
          )
              .paddingOnly(left: 30, right: 30, top: 10.0, bottom: 10)
              .decorated(
                color: ReviewWordsTheme.darkBlue,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              )
              .alignment(Alignment.topCenter),
          indexedItemBuilder: (_, Word word, index) => FadeInRight(
            duration: 0.5.seconds,
            // Delay the animation to create a staggered effect when first render
            child: SizedBox(
              height: 100,
              child: Card(
                color: ReviewWordsTheme.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                elevation: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: SimpleGestureDetector(
                  onTap: () => controller.showSingleCard(word),
                  onLongPress: () => controller.jumpToCard(index),
                  child: ListTile(
                    leading: Obx(
                      () => IconButton(
                        color: controller.indexOfWordPlaying.value == index
                            ? Colors.lightBlueAccent
                            : Colors.blueGrey,
                        padding: EdgeInsets.only(left: 20),
                        icon: Icon(FontAwesome.play_circle),
                        iconSize: BUTTON_SIZE,
                        onPressed: () => controller.playWord(index),
                      ),
                    ),
                    title: PinyinAnnotatedParagraph(
                      defaultTextStyle: ReviewWordsTheme.wordListItem,
                      pinyinTextStyle: ReviewWordsTheme.wordListItemPinyin,
                      paragraph: word.wordAsString,
                      pinyins: word.pinyin,
                    ).center(),
                  ),
                ),
              ),
            ),
          ),
          itemComparator: (element1, element2) => element1.wordId.compareTo(element2.wordId),
          // optional
          order: StickyGroupedListOrder.ASC, // optional
        ));
  }
}
