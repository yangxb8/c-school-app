// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/service/lecture_service.dart';
import '../../../util/extensions.dart';

class ReviewWordsHomeController extends GetxController {
  final LectureService lectureService = Get.find();

  /// Used to controller scroll of lectures list
  final groupedItemScrollController = GroupedItemScrollController();

  static const lastViewedLectureIndexKey = 'ReviewWordsHomeController.lastViewedLectureIndex';

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
          index: lastViewedLectureIndex.value, duration: 0.5.seconds, curve: Curves.bounceInOut);
    }
  }

  void refreshState() {
    wordsListLiked.assignAll(lectureService.getLikedWords);
    wordsListForgotten
        .assignAll(lectureService.findWordsByConditions(wordMemoryStatus: WordMemoryStatus.FORGOT));
    wordsListAll.assignAll(LectureService.allWords);
  }
}
