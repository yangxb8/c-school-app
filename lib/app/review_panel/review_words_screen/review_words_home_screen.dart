// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_home_screen_controller.dart';
import 'package:c_school_app/app/ui_view/blurhash_image_with_fallback.dart';
import 'package:c_school_app/app/ui_view/search_bar.dart';
import 'package:c_school_app/service/lecture_service.dart';
import '../../../c_school_icons.dart';
import '../../../i18n/review_words.i18n.dart';
import '../../../util/extensions.dart';
import 'review_words_theme.dart';

class ReviewWordsHomeScreen extends GetView<ReviewWordsHomeController> {
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
                  _buildSpecialLectureCard().expanded(),
                  Text('All Course'.i18n,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        letterSpacing: 0.27,
                        decoration: TextDecoration.none,
                        color: ReviewWordsTheme.darkerText,
                      )).paddingOnly(left: 20, top: 20).alignment(Alignment.centerLeft),
                  StickyGroupedListView<Lecture, String>(
                      elements: LectureService.allLectures,
                      itemScrollController: controller.groupedItemScrollController,
                      floatingHeader: true,
                      groupBy: (Lecture element) => element.levelForDisplay,
                      groupSeparatorBuilder: (_) => const SizedBox.shrink(),
                      itemComparator: (element1, element2) =>
                          element1.lectureId.compareTo(element2.lectureId),
                      indexedItemBuilder: (_, lecture, index) => FadeInRight(
                          duration: 0.5.seconds,
                          // Delay the animation to create a staggered effect
                          // when first rendered
                          child: LectureCard(
                            lecture: lecture,
                            index: index,
                          ).paddingOnly(bottom: 5))).expanded(flex: 5)
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
      );

  Widget _buildSpecialLectureCard() {
    final bigIconSize = 40.0;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.only(top: 8,left: 8),
              icon: Icon(CSchool.wrong,
                  size: bigIconSize*0.8, color: ReviewWordsTheme.darkBlue),
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: controller.wordsListForgotten.toList()),
              tooltip: 'Forgotten words'.i18n,
            ),
            _buildWordsCount(controller.wordsListForgotten)
          ],
        ).expanded(),
        Column(
          children: [
            IconButton(
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: controller.wordsListLiked.toList()),
              icon: Icon(CSchool.heart, size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              tooltip: 'Liked words'.i18n,
            ),
            _buildWordsCount(controller.wordsListLiked)
          ],
        ).expanded(),
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.only(top: 5,left: 8),
              icon:
                  Icon(CSchool.books_stack_of_three, size: bigIconSize*1.2, color: ReviewWordsTheme.darkBlue),
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: controller.wordsListAll.toList()),
              tooltip: 'All words'.i18n,
            ),
            _buildWordsCount(controller.wordsListAll)
          ],
        ).expanded(),
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

  Widget _buildWordsCount(List<Word> words) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CSchool.word_card,
            color: ReviewWordsTheme.lightYellow,
            size: 20,
          ),
          Obx(
            () => Text(
              '${words.length}',
              textAlign: TextAlign.left,
              style: ReviewWordsTheme.lectureCardMeta,
            ),
          ).paddingOnly(left: 10)
        ],
      ).paddingOnly(top:10);
}

class LectureCard extends StatelessWidget {
  LectureCard({
    Key key,
    @required this.lecture,
    this.index,
  })  : controller = Get.put(LectureCardController(lecture), tag: lecture.lectureId),
        super(key: key);

  static const cardHeight = 120.0;
  static const DEFAULT_IMAGE = 'assets/review_panel/default.png';
  final Lecture lecture;
  final int index;
  final LectureCardController controller;
  final LectureService lectureService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SimpleGestureDetector(
      onTap: () => navigateToReviewWordScreen(lecture: lecture, index: index),
      child: SizedBox(
        height: cardHeight,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 4/3,
              child: BlurHashImageWithFallback(
                fallbackImg: DEFAULT_IMAGE,
                mainImgUrl: lecture.pic.url,
                blurHash: lecture.picHash,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  '${lecture.intLectureId}. ${lecture.title}',
                  style: ReviewWordsTheme.lectureCardTitle,
                  maxLines: 1,
                ).paddingSymmetric(horizontal: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CSchool.word_card,
                          color: ReviewWordsTheme.lightYellow,
                          size: 20,
                        ),
                        Text(
                          '${lecture.words.length}',
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.lectureCardMeta,
                        ).paddingOnly(left: 10),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CSchool.wrong,
                          color: ReviewWordsTheme.lightYellow,
                          size: 20,
                        ),
                        Obx(
                              () => Text(
                            '${controller.forgottenWords.length}',
                            textAlign: TextAlign.left,
                            style: ReviewWordsTheme.lectureCardMeta,
                          ),
                        ).paddingOnly(left: 10),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CSchool.study,
                          color: ReviewWordsTheme.lightYellow,
                          size: 20,
                        ),
                        Obx(
                          () => Text(
                            '${controller.lectureViewCount}',
                            textAlign: TextAlign.left,
                            style: ReviewWordsTheme.lectureCardMeta,
                          ),
                        ).paddingOnly(left: 10),
                      ],
                    ),
                  ],
                ).paddingSymmetric(horizontal: 5)
              ],
            ).expanded()
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
  final reviewWordsHomeController = Get.find<ReviewWordsHomeController>();
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
      reviewWordsHomeController.lastViewedLectureIndex.value = index;
    }
    Get.toNamed('/review/words?lectureId=${lecture?.lectureId ?? ''}', arguments: wordsList)
        .then((_) {
      // Refresh lecture card
      if (lecture != null) {
        Get.find<LectureCardController>(tag: lecture.lectureId).refreshState();
      }
      // Refresh special card
      reviewWordsHomeController.refreshState();
    });
  }
}
