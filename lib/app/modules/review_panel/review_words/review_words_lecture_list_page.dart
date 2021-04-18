// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import '../../../core/theme/review_words_theme.dart';
import '../../../data/service/lecture_service.dart';
import '../../../core/utils/index.dart';
import '../../../core/values/icons/c_school_icons.dart';
import '../../../data/model/lecture.dart';
import '../../../data/model/word/word.dart';
import '../../../global_widgets/blurhash_image_with_fallback.dart';
import '../../../global_widgets/search_bar.dart';
import 'review_words_lecture_list_controller.dart';

// 🌎 Project imports:

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
                    'review.word.home.myWord.title'.tr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      letterSpacing: 0.27,
                      decoration: TextDecoration.none,
                      color: ReviewWordsTheme.darkerText,
                    ),
                  )
                      .paddingOnly(left: 20, top: 20)
                      .alignment(Alignment.centerLeft),
                  _buildSpecialLectureCard().expanded(),
                  Text('review.word.home.allCourse.title'.tr,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            letterSpacing: 0.27,
                            decoration: TextDecoration.none,
                            color: ReviewWordsTheme.darkerText,
                          ))
                      .paddingOnly(left: 20, top: 20)
                      .alignment(Alignment.centerLeft),
                  StickyGroupedListView<Lecture, String>(
                      elements: controller.lectureHelper.allLecture,
                      itemScrollController:
                          controller.groupedItemScrollController,
                      floatingHeader: true,
                      groupBy: (Lecture element) => element.levelForDisplay,
                      groupSeparatorBuilder: (_) => const SizedBox.shrink(),
                      itemComparator: (element1, element2) =>
                          element1.lectureId!.compareTo(element2.lectureId!),
                      indexedItemBuilder: (_, lecture, index) => LectureCard(
                            lecture: lecture,
                            index: index,
                          ).paddingOnly(bottom: 5)).expanded(flex: 5)
                ],
              ),
            )
                .afterFirstLayout(controller.animateToTrackedLecture)
                .paddingOnly(top: 40),
            _buildSearchBar()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() => SearchBar<Lecture>(
        items: controller.lectureHelper.allLecture,
        searchResultBuilder: (lecture) => ListTile(
          title: Text(
            '${lecture.intLectureId}. ${lecture.title}',
            style: ReviewWordsTheme.lectureCardTitle,
          ),
        ),
        onSearchResultTap: (lecture) =>
            navigateToReviewWordScreen(lecture: lecture),
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
              padding: EdgeInsets.only(top: 8, left: 8),
              icon: Icon(CSchool.wrong_box,
                  size: bigIconSize * 0.8, color: ReviewWordsTheme.darkBlue),
              onPressed: () => navigateToReviewWordScreen(
                  wordsList: controller.wordsListForgotten.toList()),
              tooltip: 'review.word.home.myWord.forgottenWord'.tr,
            ),
            _buildWordsCount(controller.wordsListForgotten)
          ],
        ).expanded(),
        Column(
          children: [
            IconButton(
              onPressed: () => navigateToReviewWordScreen(
                  wordsList: controller.wordsListLiked.toList()),
              icon: Icon(CSchool.heart,
                  size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              tooltip: 'review.word.home.myWord.likedWord'.tr,
            ),
            _buildWordsCount(controller.wordsListLiked)
          ],
        ).expanded(),
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.only(top: 5, left: 8),
              icon: Icon(CSchool.books_stack_of_three,
                  size: bigIconSize * 1.2, color: ReviewWordsTheme.darkBlue),
              onPressed: () => navigateToReviewWordScreen(
                  wordsList: controller.wordsListAll.toList()),
              tooltip: 'review.word.home.myWord.allWord'.tr,
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
      ).paddingOnly(top: 10);
}

class LectureCard extends StatelessWidget {
  LectureCard({
    Key? key,
    required this.lecture,
    this.index,
  })  : controller =
            Get.put(LectureCardController(lecture), tag: lecture.lectureId)!,
        super(key: key);

  static const cardHeight = 120.0;
  static const DEFAULT_IMAGE = 'assets/review_panel/default.png';
  final Lecture lecture;
  final int? index;
  final LectureCardController controller;
  final LectureService lectureHelper = Get.find<LectureService>();

  @override
  Widget build(BuildContext context) {
    if (lecture.words.isEmpty) {
      return const SizedBox.shrink();
    }
    return SimpleGestureDetector(
      onTap: () => navigateToReviewWordScreen(lecture: lecture, index: index),
      child: SizedBox(
        height: cardHeight,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: BlurHashImageWithFallback(
                fallbackImg: DEFAULT_IMAGE,
                mainImgUrl: lecture.pic!.url,
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
                          CSchool.wrong_box,
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

/// ReviewWordsController will find words by lectureId so wordsList is optional,
/// if both provided, will use wordsList
///
/// Set index will make controller to memorize the lecture last viewed
void navigateToReviewWordScreen(
    {Lecture? lecture, int? index, List<Word>? wordsList}) {
  final reviewWordsHomeController = Get.find<ReviewWordsHomeController>();
  if (lecture == null && wordsList.isBlank!) {
    Get.defaultDialog(
      title: 'error.oops'.tr,
      content: Text('review.word.home.error.noWord'.tr),
    );
  } else {
    if (index != null) {
      reviewWordsHomeController.lastViewedLectureIndex.value = index;
    }
    Get.toNamed('/review/words?lectureId=${lecture?.lectureId ?? ''}',
            arguments: wordsList)!
        .then((_) {
      // Refresh lecture card after user go back to the lecture list
      if (lecture != null &&
          Get.isRegistered<LectureCardController>(tag: lecture.lectureId)) {
        Get.find<LectureCardController>(tag: lecture.lectureId).refreshState();
      }
      // Refresh special card
      reviewWordsHomeController.refreshState();
    });
  }
}
