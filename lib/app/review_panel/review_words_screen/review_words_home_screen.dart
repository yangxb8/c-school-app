import 'package:animate_do/animate_do.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:c_school_app/app/models/class.dart';
import 'review_words_theme.dart';
import '../../../i18n/review_words.i18n.dart';

class ReviewWordsHomeScreen extends StatelessWidget {
  final ClassService classService = Get.find();
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
            _buildSpecialClassCard().expanded(flex: 1),
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
                itemCount: ClassService.allClasses.length,
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
                        ClassCard(cschoolClass: ClassService.allClasses[index])
                            .paddingOnly(bottom: 5))).expanded(flex: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialClassCard() {
    final bigIconSize = 50.0;
    var wordsListLiked = classService.getLikedWords;
    var wordsListForgotten = classService.findWordsByConditions(
        wordMemoryStatus: WordMemoryStatus.FORGOT);
    var wordsListAll = ClassService.allWords;

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
            _buildWordsCount(wordsListAll.length)
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
            style: ReviewWordsTheme.classCardMeta,
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

class ClassCard extends StatelessWidget {
  ClassCard({
    Key key,
    @required this.cschoolClass,
  }) : super(key: key);

  static const DEFAULT_IMAGE = 'assets/discover_panel/interFace3.png';
  final CSchoolClass cschoolClass;
  final ClassService classService = Get.find();

  @override
  Widget build(BuildContext context) {
    var forgottenWords = classService.findWordsByConditions(
        wordMemoryStatus: WordMemoryStatus.FORGOT,
        classId: cschoolClass.classId);
    return SimpleGestureDetector(
      onTap: () => navigateToReviewWordScreen(cschoolClass: cschoolClass),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                cschoolClass.pic?.url == null
                    ? Image.asset(DEFAULT_IMAGE)
                    : CachedNetworkImage(
                        imageUrl: cschoolClass.pic.url,
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
                  cschoolClass.levelForDisplay,
                  style: ReviewWordsTheme.classCardLevel,
                ).paddingOnly(bottom: 5),
                AutoSizeText(
                  cschoolClass.title,
                  style: ReviewWordsTheme.classCardTitle,
                  maxLines: 1,
                ).paddingOnly(right: 10,bottom: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          classService
                              .getClassViewedCount(cschoolClass)
                              .toString(),
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.classCardMeta,
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
                          '${cschoolClass.words.length}',
                          textAlign: TextAlign.left,
                          style: ReviewWordsTheme.classCardMeta,
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
                          style: ReviewWordsTheme.classCardMeta,
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

/// ReviewWordsController will find words by classId so wordsList if optional,
/// if both provided, will use wordsList
void navigateToReviewWordScreen(
    {CSchoolClass cschoolClass, List<Word> wordsList}) {
  if (cschoolClass.isNull && wordsList.isNullOrBlank) {
    final popup = BeautifulPopup(
      context: Get.context,
      template: TemplateNotification,
    );
    popup.show(
      title: '',
      barrierDismissible: true,
      content: Text(
        'Oops, No words here'.i18n,
        style: ReviewWordsTheme.classCardTitle,
      ).paddingOnly(top: 10),
    );
  } else {
    Get.toNamed('/review/words?classId=${cschoolClass?.classId ?? ''}',
        arguments: wordsList);
  }
}
