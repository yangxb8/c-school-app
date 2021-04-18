// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/core/utils/helper/api_helper.dart';
import 'package:c_school_app/app/data/repository/exam_repository.dart';
import 'package:c_school_app/app/data/repository/lecture_repository.dart';
import 'package:c_school_app/app/data/repository/user_repository.dart';
import 'package:c_school_app/app/data/repository/word_repository.dart';
import '../../../data/model/exam/exam_base.dart';
import '../../../data/model/lecture.dart';
import '../../../data/model/user/user_lecture_history.dart';
import '../../../data/model/user/user_word_history.dart';
import '../../../data/model/word/word.dart';
import '../../../global_widgets/word_card.dart';

/*
* This class provide service related to Class, like fetching class,
* words, etc.
*/
class LectureHelper {
  static final userRepository = Get.find<UserRepository>();
  final user = userRepository.currentUser;
  final lectureRepository = Get.find<LectureRepository>();
  final wordRepository = Get.find<WordRepository>();
  final examRepository = Get.find<ExamRepository>();

  /// Observable Liked words list for updating
  final RxList<String> userLikedWordIds_Rx =
      List<String>.of(userRepository.currentUser.likedWords!).obs;

  /// Observable Class History list for updating
  final RxList<LectureHistory> userLecturesHistory_Rx =
      List<LectureHistory>.of(userRepository.currentUser.reviewedClassHistory!)
          .obs;

  /// Observable Word History list for updating
  final RxList<WordHistory> userWordsHistory_Rx =
      (List<WordHistory>.of(userRepository.currentUser.reviewedWordHistory!))
          .obs;

  List<Lecture> get allLecture => lectureRepository.allLectures;

  List<Word> get allWords => wordRepository.allWords;

  List<Exam> get allExams => examRepository.allExams;

  Lecture? findLectureById(String? id) {
    if (id == null) return null;
    var lecture = lectureRepository.findLectureBy({'lectureId': id});
    if (lecture.isEmpty) {
      logger.w('Not lecture of $id is found');
      return null;
    }
    return lecture.single;
  }

  List<Word> findWordsBy(Map<String, dynamic> conditions) =>
      wordRepository.findWordBy(conditions);

  /// Get all words user liked
  List<Word> get likedWords =>
      wordRepository.findWordBy({'wordId': userLikedWordIds_Rx.toList()});

  /// remember, normal, forgot, or no_reviewed of this word
  WordMemoryStatus getMemoryStatusOfWord(Word word) {
    if (wordViewedCount(word) == 0) {
      return WordMemoryStatus.NOT_REVIEWED;
    }
    return user.reviewedWordHistory!
        .filter((record) => record.wordId == word.wordId && record.isLatest!)
        .single
        .wordMemoryStatus!;
  }

  /// If the word is in liked word list
  bool isWordLiked(Word word) => user.likedWords!.contains(word.wordId);

  /// Count how many times the word is viewed
  int wordViewedCount(Word word) => user.reviewedWordHistory!
      .filter((record) => record.wordId == word.wordId)
      .length;

  /// Return how many times the class is reviewed in words review mode
  int lectureViewedCount(Lecture lecture) => user.reviewedClassHistory!
      .filter((record) => record.lectureId == lecture.lectureId)
      .length;

  /// Like or unlike the word,
  void toggleWordLiked(Word word) {
    if (!userLikedWordIds_Rx.remove(word.wordId)) {
      userLikedWordIds_Rx.add(word.wordId!);
    }
  }

  /// Add record to reviewedWordHistory, won't overwrite it
  void addWordReviewedHistory(Word word,
      {WordMemoryStatus status = WordMemoryStatus.NORMAL}) {
    // If have history, change it to not latest
    var relatedWordHistory = userWordsHistory_Rx.filter(
        (history) => history.wordId == word.wordId && history.isLatest!);
    if (relatedWordHistory.length == 1) {
      relatedWordHistory.single.isLatest = false;
    }
    userWordsHistory_Rx.add(WordHistory(
        wordId: word.wordId,
        wordMemoryStatus: status,
        timestamp: Timestamp.now(),
        isLatest: true));
  }

  /// Find latest memory status in userWordHistory
  WordMemoryStatus findLatestMemoryStatusOfWord(Word word) {
    var relatedWordHistory = userWordsHistory_Rx.filter(
        (history) => history.wordId == word.wordId && history.isLatest!);
    return relatedWordHistory.isEmpty
        ? WordMemoryStatus.NOT_REVIEWED
        : relatedWordHistory.single.wordMemoryStatus!;
  }

  /// Add record to reviewedClassHistory, won't overwrite it
  void addLectureReviewedHistory(Lecture lecture) {
    // If have history, change it to not latest
    var relatedClassHistory = userLecturesHistory_Rx.filter((history) =>
        history.lectureId == lecture.lectureId && history.isLatest!);
    if (relatedClassHistory.length == 1) {
      relatedClassHistory.single.isLatest = false;
    }
    userLecturesHistory_Rx.add(LectureHistory(
        lectureId: lecture.lectureId,
        timestamp: Timestamp.now(),
        isLatest: true));
  }

  /// Get how many times this lecture is reviewed
  int getLectureViewedCount(Lecture lecture) => userLecturesHistory_Rx
      .count((history) => history.lectureId == lecture.lectureId);

  /// Commit any changed made to _appUserForUpdate
  void commitChange() {
    user
      ..likedWords = userLikedWordIds_Rx.toList()
      ..reviewedClassHistory = userLecturesHistory_Rx.toList()
      ..reviewedWordHistory = userWordsHistory_Rx.toList();
    userRepository.update();
  }

  /// Show a single word card from dialog
  void showSingleWordCard(Word word) {
    Get.dialog(
      SimpleDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        children: [
          WordCard(
            word: word,
            isDialog: true,
          )
        ],
      ),
      barrierColor: Get.isDialogOpen! ? Colors.transparent : null,
    );
  }
}
