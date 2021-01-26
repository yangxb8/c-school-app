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
import '../../../../util/utility.dart';

const BUTTON_SIZE = 30.0;

class WordsList extends GetView<ReviewWordsController> {
  final _groupedItemPositionsListener = ItemPositionsListener.create();

  WordsList({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: ValueListenableBuilder<Iterable<ItemPosition>>(
          valueListenable: _groupedItemPositionsListener.itemPositions,
          builder: (_, positions, __) {
            // When first rendered, minVisibleCardIndex should be 0
            final minVisibleCardIndex =
            findFirstVisibleItemIndex(positions);
            if (controller.isListFirstRender && minVisibleCardIndex > 0) {
              controller.isListFirstRender = false;
            }
            return StickyGroupedListView<Word, String>(
              elements: controller.wordsList,
              itemScrollController: controller.groupedItemScrollController,
              itemPositionsListener: _groupedItemPositionsListener,
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
                  .paddingOnly(top: 10.0, bottom: 10.0),
              indexedItemBuilder: (_, Word word, index) => FadeInRight(
                duration: 0.5.seconds,
                // Delay the animation to create a staggered effect when first render
                delay: controller.isListFirstRender
                    ? (0.3 * index).seconds
                    : 0.seconds,
                child: Card(
                  color: ReviewWordsTheme.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  elevation: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: SimpleGestureDetector(
                    onTap: () => controller.showSingleCard(word),
                    child: ListTile(
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: IconButton(
                          icon: Icon(FontAwesome.play_circle),
                          iconSize: BUTTON_SIZE,
                          onPressed: () => controller.playWord(word: word),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: PinyinAnnotatedParagraph(
                          defaultTextStyle: ReviewWordsTheme.wordListItem,
                          paragraph: word.wordAsString,
                          pinyins: word.pinyin,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              itemComparator: (element1, element2) =>
                  element1.wordId.compareTo(element2.wordId),
              // optional
              order: StickyGroupedListOrder.ASC, // optional
            );
          }),
    );
  }
}
