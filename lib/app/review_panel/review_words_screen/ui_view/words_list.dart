import 'package:flutter/material.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/app/review_panel/controller/review_words_controller.dart';

class WordsList extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    var sectionList = controller.sectionList;
    return ExpandableListView(
      builder: SliverExpandableChildDelegate<Word, WordsSection>(
          sectionList: sectionList,
          headerBuilder: (context, sectionIndex, index) =>
              Text(sectionList[sectionIndex].header),
          itemBuilder: (context, sectionIndex, itemIndex, index) {
            var word = sectionList[sectionIndex].items[itemIndex];
            return ListTile(
              trailing: IconButton(
                icon: Icon(Icons.headset),
                onPressed: ()=>controller.playWord(word: word),
              ),
              title: Row(children: [
                Text(word.word.join()),
                Text(word.pinyin.join(' '))
              ],),
            );
          }),
    );
  }
}

class WordsSection implements ExpandableListSection<Word> {
  bool expanded;
  List<Word> items;
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
