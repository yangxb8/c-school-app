import 'package:c_school_app/service/lecture_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supercharged/supercharged.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../../util/extensions.dart';

class ReviewWordsHomeController extends GetxController {
  final LectureService lectureService = Get.find();

  /// Used to controller scroll of lectures list
  final groupedItemScrollController = GroupedItemScrollController();

  /// If first time rendered, a staggered animation of lectures will be played
  bool isFirstRender = true;
  static const lastViewedLectureIndexKey =
      'ReviewWordsHomeController.lastViewedLectureIndex';

  /// Last Lecture user has viewed, default to 0 (First lecture)
  final lastViewedLectureIndex = 0.obs.trackLocal(lastViewedLectureIndexKey);

  void animateToTrackedLecture() {
    if (groupedItemScrollController.isAttached) {
      groupedItemScrollController.scrollTo(
          index: lastViewedLectureIndex.value,
          duration: 0.5.seconds,
          curve: Curves.bounceInOut);
    }
  }
}
