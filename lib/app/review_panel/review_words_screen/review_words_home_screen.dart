import 'package:animate_do/animate_do.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_home_screen_controller.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'review_words_theme.dart';
import '../../../i18n/review_words.i18n.dart';

class ReviewWordsHomeScreen extends GetView<ReviewWordsHomeController> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                    ))
                .paddingOnly(left: 20, top: 20)
                .alignment(Alignment.centerLeft),
            ListView.builder(
                controller: _scrollController,
                itemCount: LectureService.allLectures.length,
                itemBuilder: (BuildContext context, int index) => FadeInRight(
                    duration: 0.5.seconds,
                    // Only when the first time top 5 elements are shown
                    // Delay the animation to create a staggered effect
                    delay: index < 5 &&
                            _scrollController.position.userScrollDirection ==
                                ScrollDirection.reverse
                        ? (0.3 * index).seconds
                        : 0.seconds,
                    child:
                        LectureCard(lecture: LectureService.allLectures[index])
                            .paddingOnly(bottom: 5))).expanded(flex: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialLectureCard() {
    final bigIconSize = 50.0;
    var wordsListLiked = controller.lectureService.getLikedWords;
    var wordsListForgotten = controller.lectureService.findWordsByConditions(
        wordMemoryStatus: WordMemoryStatus.FORGOT);
    var wordsListAll = LectureService.allWords;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.sadCry,
                  size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: wordsListForgotten),
              tooltip: 'Forgotten words'.i18n,
            ),
            _buildWordsCount(wordsListForgotten.length)
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: wordsListLiked),
              icon: FaIcon(FontAwesomeIcons.solidHeart,
                  size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              tooltip: 'Liked words'.i18n,
            ),
            _buildWordsCount(wordsListLiked.length)
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.university,
                  size: bigIconSize, color: ReviewWordsTheme.darkBlue),
              onPressed: () =>
                  navigateToReviewWordScreen(wordsList: wordsListAll),
              tooltip: 'All words'.i18n,
            ),
            _buildWordsCount(wordsListAll?.length?? 0)
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
  }) : super(key: key);

  static const DEFAULT_IMAGE = 'assets/discover_panel/interFace3.png';
  final Lecture lecture;
  final LectureService lectureService = Get.find();

  @override
  Widget build(BuildContext context) {
    var forgottenWords = lectureService.findWordsByConditions(
        wordMemoryStatus: WordMemoryStatus.FORGOT,
        lectureId: lecture.lectureId);
    return SimpleGestureDetector(
      onTap: () => navigateToReviewWordScreen(lecture: lecture),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                lecture.pic?.url == null
                    ? Image.asset(DEFAULT_IMAGE, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: lecture.pic.url,
                        placeholder: (context, url) => BlurHash(hash: lecture.picHash),
                        errorWidget: (context, url, error) =>
                            Image.asset(DEFAULT_IMAGE),
                        fit: BoxFit.cover,
                      ).expanded(),
              ],
            ).expanded(flex: 3),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lecture.levelForDisplay,
                  style: ReviewWordsTheme.lectureCardLevel,
                ).paddingOnly(bottom: 5),
                AutoSizeText(
                  lecture.title,
                  style: ReviewWordsTheme.lectureCardTitle,
                  maxLines: 1,
                ).paddingOnly(right: 10,bottom: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lectureService
                              .getLectureViewedCount(lecture)
                              .toString(),
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
                          child: FaIcon(
                            FontAwesomeIcons.sadCry,
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
/// if both provided, will use wordsList
void navigateToReviewWordScreen(
    {Lecture lecture, List<Word> wordsList}) {
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
    Get.toNamed('/review/words?lectureId=${lecture?.lectureId ?? ''}',
        arguments: wordsList);
  }
}
