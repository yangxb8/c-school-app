import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spoken_chinese/controller/review_words_controller.dart';
import 'ui_view/words_flashcard.dart';
import 'ui_view/words_list.dart';

class ReviewWords extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
              Color(0xFF1b1e44),
              Color(0xFF2d3447),
            ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                tileMode: TileMode.clamp)),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Stack(fit: StackFit.expand, children: [
              Obx(() => controller.mode == WordsReviewMode.FLASH_CARD
                  ? WordsFlashcard()
                  : WordsList()),
              _buildFloatingSearchBar(),
            ])));
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
        // Call your model, bloc, controller here.
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
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Container(height: 112)]),
          ),
        );
      },
    );
  }
}
