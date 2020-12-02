import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import './ui_view/words_flashcard.dart';
import './ui_view/words_list.dart';

class ReviewWords extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(fit: StackFit.expand, children: [
          Obx(() => controller.mode == WordsReviewMode.FLASH_CARD
              ? WordsFlashcard()
              : WordsList()),
          _buildFloatingSearchBar(),
        ]));
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
        controller.searchQuery.value=query;
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          child: CircularButton(
            icon: Obx(() => controller.mode == WordsReviewMode.LIST
                ? Icon(Icons.credit_card)
                : Icon(Icons.list)),
            onPressed: () => controller.changeMode(),
          ),
        ),
        FloatingSearchBarAction(
          child: CircularButton(
            icon: Obx(() => FaIcon(
                  FontAwesomeIcons.play,
                  color: controller.isAutoPlayMode
                      ? Colors.lightBlue
                      : Colors.grey,
                )),
            onPressed: () => controller.autoPlayPressed(),
          ),
        )
      ],
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
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
                  children: _buildSearchResult()
                ),
              ),
            ));
      },
    );
  }

  //TODO: distinguish empty keyword, not result, and there is result
  List<Widget> _buildSearchResult() {
    return controller.searchResult
        .map((word) => Text(word.wordAsString))
        .toList();
  }
}
