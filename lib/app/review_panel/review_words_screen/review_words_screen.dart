import 'package:c_school_app/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:simple_animations/simple_animations.dart';
import './ui_view/words_flashcard.dart';
import './ui_view/words_list.dart';
import 'package:c_school_app/i18n/review_words.i18n.dart';

class ReviewWords extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(fit: StackFit.expand, children: [
            Obx(() => controller.mode == WordsReviewMode.flash_card
                ? WordsFlashcard()
                : WordsList()),
            _buildFloatingSearchBar(),
          ]),
        ));
  }

  FloatingSearchBar _buildFloatingSearchBar() {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: controller.searchBarController,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      maxWidth: 600,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        controller.searchQuery.value = query;
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          child: CircularButton(
            icon: Obx(() => controller.mode == WordsReviewMode.list
                ? Icon(Icons.credit_card)
                : Icon(Icons.list)),
            onPressed: () => controller.changeMode(),
          ),
        ),
        FloatingSearchBarAction(
          child: CircularButton(
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
            onPressed: () => controller.autoPlayPressed(),
          ),
        ),
        FloatingSearchBarAction(
          child: CircularButton(
            icon: Obx(() => controller.speakerGender.value == SpeakerGender.male
                ? Icon(Ionicons.md_male)
                : Icon(Ionicons.md_female)),
            onPressed: () => controller.toggleSpeakerGender(),
          ),
        ),
      ],
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: CircularButton(
            icon: Icon(Icons.contact_support),
            onPressed: () => UserService.showWireDash(),
          ),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Obx(
                () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: controller.searchResult.isEmpty
                        ? [
                            ListTile(
                                title: Text('Empty'.i18n,
                                    style: TextStyle(color: Colors.grey)))
                          ]
                        : controller.searchResult
                            .map((word) => ListTile(
                                title: TextButton(
                                    child: Text(word.wordAsString),
                                    onPressed: () {
                                      controller.searchBarController.close();
                                      controller.showSingleCard(word);
                                    })))
                            .toList()),
              ),
            ));
      },
    );
  }
}
