// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../../../core/theme/review_words_theme.dart';
import '../../../core/values/icons/c_school_icons.dart';
import '../../../data/model/word/word.dart';
import '../../../global_widgets/search_bar.dart';
import 'review_words_detail_controller.dart';
import 'widgets/words_flashcard.dart';
import 'widgets/words_list.dart';

class ReviewWords extends GetView<ReviewWordsController> {
  SearchBar _buildSearchBar() {
    return SearchBar<Word>(
      items: controller.wordsList,
      searchResultBuilder: (word) => ListTile(
        title: Text(
          word.wordAsString,
          style: ReviewWordsTheme.wordListItem,
        ).paddingOnly(left: 20),
        trailing: Text(
          word.wordMeanings!.first.meaning!,
          style: ReviewWordsTheme.wordListItem,
        ),
      ).paddingOnly(right: 20),
      onSearchResultTap: (word) => controller.showSingleCard(word),
      automaticallyImplyBackButton: true,
      leadingActions: [
        CircularButton(
          icon: Obx(() => controller.mode == WordsReviewMode.list
              ? Icon(Icons.credit_card)
              : Icon(Icons.list)),
          onPressed: controller.changeMode,
        ),
        CircularButton(
          icon: Obx(
            () => CustomAnimation<Color>(
              control: controller.searchBarPlayIconControl.value,
              tween: Colors.grey
                  .tweenTo(Colors.lightBlueAccent)
                  .curved(Curves.bounceInOut) as Animatable<Color>,
              duration: 0.3.seconds,
              builder: (_, __, value) => AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                size: 30,
                color: value,
                progress: controller.searchBarPlayIconController,
              ),
            ),
          ),
          onPressed: controller.autoPlayPressed,
        ),
        CircularButton(
          icon: Obx(() => controller.speakerGender.value == SpeakerGender.male
              ? Icon(CSchool.male)
              : Icon(CSchool.female)),
          onPressed: controller.toggleSpeakerGender,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(fit: StackFit.expand, children: [
            Obx(() => controller.mode == WordsReviewMode.flash_card
                ? WordsFlashcard()
                : WordsList()),
            _buildSearchBar(),
          ]),
        ));
  }
}
