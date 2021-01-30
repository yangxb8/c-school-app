import 'package:animate_do/animate_do.dart';
import 'package:c_school_app/app/ui_view/blurhash_image_with_fallback.dart';
import 'package:c_school_app/app/ui_view/search_bar.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_home_screen_controller.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'review_words_theme.dart';
import '../../../i18n/review_words.i18n.dart';
import '../../../util/functions.dart';
import '../../../util/extensions.dart';

class ReviewWordsHomeScreen extends GetView<ReviewWordsHomeController> {
  final _groupedItemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Text(
                    'My Words'.i18n,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      letterSpacing: 0.27,
                      decoration: TextDecoration.none,
                      color: ReviewWordsTheme.darkerText,
                    ),
                  ).paddingOnly(left: 20, top: 20).alignment(Alignment.centerLeft),
                  _buildSpecialLectureCard().expanded(flex: 1),
                  Text('All Course'.i18n,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        letterSpacing: 0.27,
                        decoration: TextDecoration.none,
                        color: ReviewWordsTheme.darkerText,
                      )).paddingOnly(left: 20, top: 20).alignment(Alignment.centerLeft),
                  ValueListenableBuilder<Iterable<ItemPosition>>(
                      valueListenable: _groupedItemPositionsListener.itemPositions,
                      builder: (_, positions, __) {
                        // When first rendered, minVisibleCardIndex should be 0
                        final minVisibleCardIndex = findFirstVisibleItemIndex(positions);
                        if (controller.isFirstRender && minVisibleCardIndex > 0) {
                          controller.isFirstRender = false;
                        }
                        return StickyGroupedListView<Lecture, String>(
                            elements: LectureService.allLectures,
                            itemScrollController: controller.groupedItemScrollController,
                            itemPositionsListener: _groupedItemPositionsListener,
                            floatingHeader: true,
                            groupBy: (Lecture element) => element.levelForDisplay,
                            groupSeparatorBuilder: (_) => const SizedBox.shrink(),
                            itemComparator: (element1, element2) =>
                                element1.lectureId.compareTo(element2.lectureId),
                            indexedItemBuilder: (_, lecture, index) => FadeInRight(
                                duration: 0.5.seconds,
                                // Delay the animation to create a staggered effect
                                // when first rendered
                                delay: controller.isFirstRender ? (0.3 * index).seconds : 0.seconds,
                                child: LectureCard(
                                  lecture: lecture,
                                  index: index,
                                ).paddingOnly(bottom: 5))).expanded(flex: 5);
                      }),
                ],
              ),
            ).afterFirstLayout(controller.animateToTrackedLecture).paddingOnly(top: 40),
            _buildSearchBar()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() => SearchBar<Lecture>(
        items: LectureService.allLectures,
        searchResultBuilder: (lecture) => ListTile(
          title: Text(
            '${lecture.intLectureId}. ${lecture.title}',
            style: ReviewWordsTheme.lectureCardTitle,
          ),
        ),
        onSearchResultTap: (lecture) => navigateToReviewWordScreen(lecture: lecture),
        automaticallyImplyBackButton: false,
      );

  Widget _buildSpecialLectureCard() {
    final bigIconSize = 50.0;
    var wordsListLiked = controller.lectureService.getLikedWords;
    var wordsListForgotten =
        controller.lectureService.findWordsByConditions(wordMemoryStatus: WordMemoryStatus.FORGOT);
    var wordsListAll = LectureService.allWords;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            IconButton(
              icon: Icon(MaterialCommunityIcons.emoticon_cry_outline,
                  size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              onPressed: () => navigateToReviewWordScreen(wordsList: wordsListForgotten),
              tooltip: 'Forgotten words'.i18n,
            ),
            _buildWordsCount(wordsListForgotten.length)
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () => navigateToReviewWordScreen(wordsList: wordsListLiked),
              icon: Icon(FontAwesome.heart, size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              tooltip: 'Liked words'.i18n,
            ),
            _buildWordsCount(wordsListLiked.length)
          ],
        ),
        Column(
          children: [
            IconButton(
              icon:
                  Icon(FontAwesome.university, size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              onPressed: () => navigateToReviewWordScreen(wordsList: wordsListAll),
              tooltip: 'All words'.i18n,
            ),
            _buildWordsCount(wordsListAll?.length ?? 0)
          ],
        ),
      ],
    )
        .paddingOnly(top: 3, right: 20)
        .card(
          color: ReviewWordsTheme.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        )
        .paddingSymmetric(horizontal: 10);
  }

  Widget _buildWordsCount(int words) => Row(
        children: [
          Text(
            '$words',
            textAlign: TextAlign.left,
            style: ReviewWordsTheme.lectureCardMeta,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.menu_book,
              color: ReviewWordsTheme.lightYellow,
              size: 20,
            ),
          ),
        ],
      ).paddingOnly(top: 25, left: 15);
}

class LectureCard extends StatelessWidget {
  LectureCard({
    Key key,
    @required this.lecture,
    this.index,
  }) : super(key: key);
  static const cardHeight = 120.0;
  static const DEFAULT_IMAGE = 'assets/review_panel/default.png';
  final Lecture lecture;
  final int index;
  final LectureService lectureService = Get.find();

  @override
  Widget build(BuildContext context) {
    var forgottenWords = lectureService.findWordsByConditions(
        wordMemoryStatus: WordMemoryStatus.FORGOT, lectureId: lecture.lectureId);
    return SimpleGestureDetector(
      onTap: () => navigateToReviewWordScreen(lecture: lecture, index: index),
      child: SizedBox(
        height: cardHeight,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlurHashImageWithFallback(
                  fallbackImg: DEFAULT_IMAGE,
                  mainImg: lecture.pic.url,
                  blurHash: lecture.picHash,
                ).expanded(),
              ],
            ).expanded(flex: 3),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AutoSizeText(
                  '${lecture.intLectureId}. ${lecture.title}',
                  style: ReviewWordsTheme.lectureCardTitle,
                  maxLines: 2,
                ).paddingOnly(right: 10, bottom: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lectureService.getLectureViewedCount(lecture).toString(),
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.lectureCardMeta,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.remove_red_eye,
                            color: ReviewWordsTheme.lightYellow,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${lecture.words.length}',
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.lectureCardMeta,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.menu_book,
                            color: ReviewWordsTheme.lightYellow,
                            size: 20,
                          ),
                        ),
                      ],
                    ).paddingOnly(left: 20),
                    Row(
                      children: [
                        Text(
                          forgottenWords.length.toString(),
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.lectureCardMeta,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(
                            MaterialCommunityIcons.emoticon_cry_outline,
                            color: ReviewWordsTheme.lightYellow,
                            size: 20,
                          ),
                        ),
                      ],
                    ).paddingOnly(left: 20)
                  ],
                )
              ],
            ).paddingOnly(left: 20).expanded(flex: 4)
          ],
        ),
      )
          .card(
            color: ReviewWordsTheme.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          )
          .paddingSymmetric(horizontal: 10),
    );
  }
}

/// ReviewWordsController will find words by lectureId so wordsList if optional,
/// Set index will make controller to memorize the lecture last viewed
/// if both provided, will use wordsList
void navigateToReviewWordScreen({Lecture lecture, int index, List<Word> wordsList}) {
  if (lecture == null && wordsList.isBlank) {
    final popup = BeautifulPopup(
      context: Get.context,
      template: TemplateNotification,
    );
    popup.show(
      title: '',
      barrierDismissible: true,
      content: Text(
        'Oops, No words here'.i18n,
        style: ReviewWordsTheme.lectureCardTitle,
      ).paddingOnly(top: 10),
    );
  } else {
    if (index != null) {
      Get.find<ReviewWordsHomeController>().lastViewedLectureIndex.value = index;
    }
    Get.toNamed('/review/words?lectureId=${lecture?.lectureId ?? ''}', arguments: wordsList);
  }
}
