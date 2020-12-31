import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:c_school_app/app/model/word_example.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/app/ui_view/pinyin_annotated_paragraph.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flip/flip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import '../model/word.dart';
import '../../i18n/review_words.i18n.dart';

final cardAspectRatio = 12.0 / 22.0;
final BUTTON_SIZE = 25.0.r;
final verticalInset = 8.0.w;
final DEFAULT_IMAGE = 'assets/review_panel/image_01.png';

class WordCard extends StatelessWidget {
  final Word word;
  final double delta;
  final WordCardController controller;
  WordCard({Key key, @required this.word, this.delta = 0.0})
      : controller = Get.put(WordCardController(word), tag: word.wordId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var hint = SimpleGestureDetector(
      onTap: controller.toggleHint,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
        child: Obx(
          () => SimpleTooltip(
            tooltipTap: controller.toggleHint,
            tooltipDirection: TooltipDirection.down,
            borderColor: Colors.transparent,
            show: controller.isHintShown.value,
            ballonPadding:
                EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
            maxWidth: Get.width * 0.7,
            content: Text(
              word.hint,
              style: ReviewWordsTheme.wordCardHint,
            ),
            child: FaIcon(FontAwesomeIcons.lightbulb,
                color: controller.isHintShown.value
                    ? ReviewWordsTheme.lightYellow
                    : ReviewWordsTheme.lightBlue,
                size: BUTTON_SIZE),
          ),
        ),
      ),
    );
    var frontCardContent = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...word.wordMeanings
                        .map((e) => Text(
                              e.meaning,
                              style: ReviewWordsTheme.wordCardMeaning,
                            ))
                        .toList(),
                    if (!word.hint.isNullOrBlank) hint else Container()
                  ],
                ),
              ],
            ).backgroundColor(ReviewWordsTheme.lightBlue),
            flex: 11),
        Expanded(
            child: word.pic?.url == null
                ? Image.asset(
                    DEFAULT_IMAGE,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: word.pic.url,
                    placeholder: (context, url) => SizedBox(
                          width: 200.0.w,
                          height: 100.0.h,
                          child: BlurHash(hash: word.picHash),
                        ),
                    errorWidget: (context, url, error) => Image.asset(
                          DEFAULT_IMAGE,
                          fit: BoxFit.cover,
                        )),
            flex: 10)
      ],
    );
    var favoriteIcon = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => IconButton(
            splashRadius: 0.01.r,
            icon: FaIcon(FontAwesomeIcons.solidHeart),
            // key: favoriteButtonKey,
            color: controller.isWordLiked()
                ? ReviewWordsTheme.lightYellow
                : Colors.grey,
            iconSize: BUTTON_SIZE * 1.2,
            onPressed: () => controller.toggleFavoriteCard(),
          ).paddingOnly(top: 10.h, right: 10.w),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0.r),
      child: SimpleGestureDetector(
        onTap: () => controller.flipController.flip(),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(3.0.w, 6.0.h),
                blurRadius: 10.0.r)
          ]),
          child: AspectRatio(
            aspectRatio: cardAspectRatio,
            child: Flip(
              controller: controller.flipController,
              flipDirection: Axis.vertical,
              flipDuration: Duration(milliseconds: 200),
              secondChild: Stack(
                  children: [buildBackCardContent(delta: delta), favoriteIcon]),
              firstChild: Stack(children: [frontCardContent, favoriteIcon]),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackCardContent({double delta = 0.0}) {
    // Top hanzi part
    var partHanZi = SimpleGestureDetector(
      onTap: controller.playWord,
      child: Center(
        child: PinyinAnnotatedParagraph(
            paragraph: word.wordAsString,
            pinyins: word.pinyin,
            defaultTextStyle: ReviewWordsTheme.wordCardWord),
      ),
    );
    // Second meaning part
    var partMeanings = word.wordMeanings.map((meaning) {
      var partExample = meaning.examples
          .map((wordExample) => _buildExampleRow(wordExample))
          .toList();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: partExample,
      );
    }).toList();
    return Column(
      children: <Widget>[
        Expanded(child: partHanZi, flex: 2),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: partMeanings,
          ),
          flex: 3,
        ),
      ],
    ).backgroundColor(ReviewWordsTheme.lightBlue);
  }

  Widget _buildExampleRow(WordExample wordExample) {
    return Column(
      children: [
        Text(
          'Example'.i18n,
          style: ReviewWordsTheme.wordCardSubTitle,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 10.w),
        PinyinAnnotatedParagraph(
          paragraph: wordExample.example,
          pinyins: wordExample.pinyin,
          defaultTextStyle: ReviewWordsTheme.wordCardExample,
          pinyinTextStyle: ReviewWordsTheme.wordCardExamplePinyin,
          centerWord: word,
          centerWordTextStyle: ReviewWordsTheme.wordCardExampleCenterWord,
          linkedWords: word.relatedWords,
          linkedWordTextStyle: ReviewWordsTheme.wordCardExampleLinkedWord,
        ).alignment(Alignment.centerLeft).paddingOnly(left: 10.w),
        Row(children: [
          Text(wordExample.meaning, style: ReviewWordsTheme.exampleMeaning)
              .paddingOnly(left: 10.w)
        ]),
        divider()
      ],
    );
  }

  Widget divider() => Divider(
        thickness: 1.h,
        height: 30.0.h,
        indent: 20.w,
        endIndent: 20.w,
        color: ReviewWordsTheme.lightYellow,
      );
}
