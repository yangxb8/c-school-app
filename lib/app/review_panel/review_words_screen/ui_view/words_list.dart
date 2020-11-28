import 'package:flutter/material.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/app/review_panel/controller/review_words_controller.dart';

import '../review_words_theme.dart';

class WordsList extends GetView<ReviewWordsController> {
  @override
  Widget build(BuildContext context) {
    var sectionList = controller.sectionList;
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: ExpandableListView(
        builder: SliverExpandableChildDelegate<Word, WordsSection>(
            sectionList: sectionList,
            headerBuilder: (context, sectionIndex, index) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6.0)),
                        color: ReviewWordsTheme.nearlyBlue.withOpacity(0.7)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(sectionList[sectionIndex].header,
                                style: TextStyle(fontSize: 25)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            itemBuilder: (context, sectionIndex, itemIndex, index) {
              var word = sectionList[sectionIndex].items[itemIndex];
              return ListTile(
                trailing: Padding(
                  padding: const EdgeInsets.only(right:20.0),
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.play),
                    onPressed: () => controller.playWord(word: word),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      Text(word.word.join()),
                      Text(word.pinyin.join(' '))
                    ],
                  ),
                ),
              );
            }),
      ),
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
