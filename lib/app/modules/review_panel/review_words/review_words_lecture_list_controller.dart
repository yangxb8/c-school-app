// 🐦 Flutter imports:
// 🌎 Project imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:supercharged/supercharged.dart';

import '../../../core/utils/index.dart';
import '../../../data/model/lecture.dart';
import '../../../data/model/word/word.dart';
// 🌎 Project imports:
import '../../../core/service/lecture_service.dart';

class ReviewWordsHomeController extends GetxController {
  static const lastViewedLectureIndexKey =
      'ReviewWordsHomeController.lastViewedLectureIndex';

  /// Used to controller scroll of lectures list
  final groupedItemScrollController = GroupedItemScrollController();

  /// Last Lecture user has viewed, default to 0 (First lecture)
  final lastViewedLectureIndex = 0.obs.trackLocal(lastViewedLectureIndexKey);

  final LectureService lectureHelper = Get.find<LectureService>();

  /// All words
  RxList<Word> wordsListAll = <Word>[].obs;

  /// Forgotten words
  RxList<Word> wordsListForgotten = <Word>[].obs;

  /// Liked words
  RxList<Word> wordsListLiked = <Word>[].obs;

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
    wordsListForgotten.assignAll(lectureHelper
        .findWordsBy({'wordMemoryStatus': WordMemoryStatus.FORGOT}));
    wordsListAll.assignAll(lectureHelper.allWords);
  }
}

class LectureCardController extends GetxController {
  LectureCardController(this.lecture);

  /// Forgotten words in this lecture
  final RxList<Word> forgottenWords = <Word>[].obs;

  /// Lecture this card is associated with
  final Lecture lecture;

  final LectureService lectureHelper = Get.find<LectureService>();

  /// How many times this lecture has been viewed
  final RxInt lectureViewCount = (-1).obs;

  @override
  void onInit() {
    refreshState();
    super.onInit();
  }

  void refreshState() {
    forgottenWords.assignAll(lectureHelper.findWordsBy({
      'wordMemoryStatus': WordMemoryStatus.FORGOT,
      'lectureId': lecture.lectureId
    }));
    lectureViewCount.value = lectureHelper.getLectureViewedCount(lecture);
  }
}