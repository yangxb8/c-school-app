// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/searchable.dart';
import '../model/searchable.dart';

/// Builder of search result
typedef SearchBarResultBuilder<T> = Widget Function(T item);

typedef SearchResultTap<T> = void Function(T item);

/// Floating Search bar for a searchable type
class SearchBar<T extends Searchable> extends StatelessWidget {
  /// Searchable items
  final Iterable<T> items;

  /// Action buttons before search field
  final List<Widget> leadingActions;

  /// Action buttons after search field
  final List<Widget> tailingActions;

  /// Widget to show when result is empty
  final Widget? emptyWidget;

  /// Builder for result items
  final SearchBarResultBuilder<T> searchResultBuilder;

  /// Function to run when result is tapped
  final SearchResultTap<T> onSearchResultTap;

  /// If empty, all searchableProperties can be used. Or you can specify it by names
  final List<String>? searchEnableProperties;

  final automaticallyImplyBackButton;

  /// Controller of this search bar
  final _SearchBarController<T> _controller;

  SearchBar(
      {Key? key,
      required this.items,
      required this.searchResultBuilder,
      required this.onSearchResultTap,
      this.leadingActions = const [],
      this.tailingActions = const [],
      this.searchEnableProperties,
      this.emptyWidget = defaultEmptyResult,
      this.automaticallyImplyBackButton = false})
      : _controller = Get.put(_SearchBarController<T>(items))!,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: _controller.searchBarController,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 500),
      automaticallyImplyBackButton: automaticallyImplyBackButton,
      onQueryChanged: (query) {
        _controller.searchQuery.value = query;
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: leadingActions
          .map((action) => FloatingSearchBarAction(child: action))
          .toList(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        ...tailingActions
            .map((action) => FloatingSearchBarAction(child: action))
            .toList()
      ],
      builder: (context, transition) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Obx(
                () => ListView(shrinkWrap: true, children: buildResult())
                    .constrained(maxHeight: 400),
              ),
            ));
      },
    );
  }

  List<Widget> buildResult() {
    if (_controller.searchResult.isEmpty) {
      return emptyWidget == null ? [defaultEmptyResult] : [emptyWidget!];
    } else {
      return _controller.searchResult
          .map((item) => SimpleGestureDetector(
              onTap: () {
                _controller.searchBarController.close();
                onSearchResultTap(item);
              },
              child: searchResultBuilder(item)))
          .toList();
    }
  }

  static const defaultEmptyResult =
      ListTile(title: Text('なし', style: TextStyle(color: Colors.grey)));
}

class _SearchBarController<T extends Searchable> extends GetxController {
  final Iterable<T> items;
  final searchBarController = FloatingSearchBarController();
  final searchQuery = ''.obs;
  final searchResult = <T>[].obs;
  _SearchBarController(this.items);

  @override
  void onInit() {
    // worker to monitor search query change and fire search function
    debounce(searchQuery, (dynamic _) => search(), time: 0.5.seconds);
    super.onInit();
  }

  /// Search card content, consider a match if word or meaning contains query
  void search() {
    if (searchQuery.value.isBlank!) {
      searchResult.clear();
      return;
    }
    searchResult.clear();
    searchResult.addAll(items.searchFuzzy(searchQuery.value));
  }
}
