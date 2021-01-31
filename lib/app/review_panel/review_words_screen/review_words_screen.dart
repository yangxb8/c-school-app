import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/review_panel/review_words_screen/review_words_theme.dart';
import 'package:c_school_app/app/ui_view/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:simple_animations/simple_animations.dart';
import './ui_view/words_flashcard.dart';
import './ui_view/words_list.dart';

class ReviewWords extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(fit: StackFit.expand, children: [
            Obx(() =>
                controller.mode == WordsReviewMode.flash_card ? WordsFlashcard() : WordsList()),
            _buildSearchBar(),
          ]),
        ));
  }

  SearchBar _buildSearchBar() {
    return SearchBar<Word>(
      items: controller.wordsList,
      searchResultBuilder: (word) => ListTile(
        title: Text(
          word.wordAsString,
          style: ReviewWordsTheme.wordListItem,
        ),
        trailing: Text(
          word.wordMeanings.first.meaning,
          style: ReviewWordsTheme.wordListItem,
        ),
      ),
      onSearchResultTap: (word) => controller.showSingleCard(word),
      automaticallyImplyBackButton: true,
      leadingActions: [
        CircularButton(
          icon: Obx(() =>
              controller.mode == WordsReviewMode.list ? Icon(Icons.credit_card) : Icon(Icons.list)),
          onPressed: controller.changeMode,
        ),
        CircularButton(
          icon: Obx(
            () => CustomAnimation<Color>(
              control: controller.searchBarPlayIconControl.value,
              tween: Colors.grey.tweenTo(Colors.lightBlueAccent),
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
              ? Icon(Ionicons.md_male)
              : Icon(Ionicons.md_female)),
          onPressed: controller.toggleSpeakerGender,
        )
      ],
    );
  }
}
