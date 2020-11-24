import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:spoken_chinese/controller/review_words_controller.dart';

class WordsList extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    var value = true;
    return ExpandableListView(
      builder: SliverExpandableChildDelegate<String, ExampleSection>(
          sectionList: controller.sectionList,
          headerBuilder: (context, sectionIndex, index) =>
              Text(controller.getSectionHeader(sectionIndex)),
          itemBuilder: (context, sectionIndex, itemIndex, index) {
            Word word = sectionList[sectionIndex].items[itemIndex];
            return ListTile(
              trailing: TextButton(
                child: Text("$index"),
              ),
              title: Text(item),
            );
          }),
    );
  }
}

class WordsSection implements ExpandableListSection<Word> {
  //store expand state.
  bool expanded;
  //return item model list.
  List<Word> items;

  //example header, optional
  String header;

  @override
  List<Word> getItems() {
    return items;
  }

  @override
  bool isSectionExpanded() {
    return expanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    this.expanded = expanded;
  }
}
