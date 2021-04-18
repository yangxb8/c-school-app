// 🐦 Flutter imports:
// 🌎 Project imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../../../core/utils/helper/lecture_helper.dart';
import '../../../core/utils/index.dart';
import '../../../data/model/lecture.dart';
import '../../../data/model/word/word.dart';

class ReviewWordsHomeController extends GetxController {
  final LectureHelper lectureHelper = LectureHelper();

  /// Used to controller scroll of lectures list
  final groupedItemScrollController = GroupedItemScrollController();

  static const lastViewedLectureIndexKey =
      'ReviewWordsHomeController.lastViewedLectureIndex';

  /// Last Lecture user has viewed, default to 0 (First lecture)
  final lastViewedLectureIndex = 0.obs.trackLocal(lastViewedLectureIndexKey);

  /// Liked words
  RxList<Word> wordsListLiked = <Word>[].obs;

  /// Forgotten words
  RxList<Word> wordsListForgotten = <Word>[].obs;

  /// All words
  RxList<Word> wordsListAll = <Word>[].obs;

  @override
  void onInit() {
    refreshState();
    super.onInit();
  }

  void animateToTrackedLecture() {
    if (groupedItemScrollController.isAttached) {
      groupedItemScrollController.scrollTo(
          index: lastViewedLectureIndex.value,
          duration: 0.5.seconds,
          curve: Curves.bounceInOut);
    }
  }

  void refreshState() {
    wordsListLiked.assignAll(lectureHelper.likedWords);
    wordsListForgotten.assignAll(lectureHelper.findWordsBy({
      'wordMemoryStatus': EnumToString.convertToString(WordMemoryStatus.FORGOT)
    }));
    wordsListAll.assignAll(lectureHelper.allWords);
  }
}

class LectureCardController extends GetxController {
  final LectureHelper lectureHelper = Get.find();

  /// Lecture this card is associated with
  final Lecture lecture;

  /// Forgotten words in this lecture
  final RxList<Word> forgottenWords = <Word>[].obs;

  /// How many times this lecture has been viewed
  final RxInt lectureViewCount = (-1).obs;

  LectureCardController(this.lecture);

  @override
  void onInit() {
    refreshState();
    super.onInit();
  }

  void refreshState() {
    forgottenWords.assignAll(lectureHelper.findWordsBy({
      'wordMemoryStatus': EnumToString.convertToString(WordMemoryStatus.FORGOT),
      'lectureId': lecture.lectureId
    }));
    lectureViewCount.value = lectureHelper.getLectureViewedCount(lecture);
  }
}
