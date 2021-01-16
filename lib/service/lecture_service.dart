import 'package:c_school_app/app/model/exam_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:c_school_app/model/user_lecture_history.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:supercharged/supercharged.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/word.dart';
import 'api_service.dart';
import '../app/ui_view/word_card.dart';

/*
* This class provide service related to Class, like fetching class,
* words, etc.
*/
class LectureService extends GetxService {
  static LectureService _instance;
  static final ApiService _apiService = Get.find();

  /// All classes available
  static List<Lecture> allLectures;

  /// All words available
  static List<Word> allWords;

  /// All exams available
  static List<Exam> allExams;

  /// Observable Liked words list for updating
  static RxList<String> userLikedWordIds_Rx;

  /// Observable Class History list for updating
  static RxList<LectureHistory> userLecturesHistory_Rx;

  /// Observable Word History list for updating
  static RxList<WordHistory> userWordsHistory_Rx;

  static Future<LectureService> getInstance() async {
    if (_instance == null) {
      _instance = LectureService();

      /// All available Lectures
      allLectures = await _apiService.firestoreApi.fetchLectures();

      /// All available words
      allWords = await _apiService.firestoreApi.fetchWords();

      /// All available exams
      allExams = await _apiService.firestoreApi.fetchExams();

      /// This properties need to be observable and can be use to update AppUser
      userLikedWordIds_Rx = List<String>.of(UserService.user.likedWords).obs;

      /// This properties need to be observable and can be use to update AppUser
      userLecturesHistory_Rx =
          (List<LectureHistory>.of(UserService.user.reviewedClassHistory)).obs;

      /// This properties need to be observable and can be use to update AppUser
      userWordsHistory_Rx =
          (List<WordHistory>.of(UserService.user.reviewedWordHistory)).obs;
    }

    return _instance;
  }

  /// Get all words user liked
  List<Word> get getLikedWords => findWordsByIds(userLikedWordIds_Rx);

  List<Word> findWordsByConditions(
      {WordMemoryStatus wordMemoryStatus, String lectureId}) {
    if (wordMemoryStatus == null && lectureId == null) {
      return [];
    }
    var latestReviewHistory = UserService.user.reviewedWordHistory
        .filter((record) => record.isLatest);
    var filteredHistory = latestReviewHistory.filter((record) {
      if (wordMemoryStatus != null &&
          wordMemoryStatus != record.wordMemoryStatus) {
        return false;
      }
      if (lectureId != null && lectureId != record.lectureId) {
        return false;
      }
      return true;
    });
    var wordIdsOfMemoryStatus = filteredHistory.map((e) => e.wordId);
    return findWordsByIds(wordIdsOfMemoryStatus.toList());
  }

  List<Word> findWordsByIds(List<String> ids) {
    if (ids.isBlank) {
      return [];
    } else {
      return allWords.filter((word) => ids.contains(word.wordId)).toList();
    }
  }

  List<Word> findWordsByTags(List<String> tags) {
    if (tags.isBlank) {
      return [];
    } else {
      return allWords
          .filter((word) => tags.every((tag) => word.tags.contains(tag)))
          .toList();
    }
  }

  List<Exam> findExamsByTags(List<String> tags) {
    if (tags.isBlank) {
      return [];
    } else {
      return allExams
          .filter((exam) => tags.every((tag) => exam.tags.contains(tag)))
          .toList();
    }
  }

  Exam findExamById(String id) {
    if (id.isBlank) {
      return null;
    } else {
      return allExams.filter((exam) => id == exam.examId).single;
    }
  }

  Lecture findLectureById(String id) {
    if (id.isBlank) {
      return null;
    } else {
      return allLectures.filter((lecture) => id == lecture.lectureId).single;
    }
  }

  List<Lecture> findLecturesByTags(List<String> tags) {
    if (tags.isBlank) {
      return [];
    } else {
      return allLectures
          .filter((lecture) => tags.every((tag) => lecture.tags.contains(tag)))
          .toList();
    }
  }

  /// remember, normal, forgot, or no_reviewed of this word
  WordMemoryStatus getMemoryStatusOfWord(Word word) {
    if (wordViewedCount(word) == 0) {
      return WordMemoryStatus.NOT_REVIEWED;
    }
    return UserService.user.reviewedWordHistory
        .filter((record) => record.wordId == word.wordId && record.isLatest)
        .single
        .wordMemoryStatus;
  }

  /// If the word is in liked word list
  bool isWordLiked(Word word) =>
      UserService.user.likedWords.contains(word.wordId);

  /// Count how many times the word is viewed
  int wordViewedCount(Word word) => UserService.user.reviewedWordHistory
      .filter((record) => record.wordId == word.wordId)
      .length;

  /// Return how many times the class is reviewed in words review mode
  int lectureViewedCount(Lecture lecture) =>
      UserService.user.reviewedClassHistory
          .filter((record) => record.lectureId == lecture.lectureId)
          .length;

  /// Like or unlike the word,
  void toggleWordLiked(Word word) {
    if (!userLikedWordIds_Rx.remove(word.wordId)) {
      userLikedWordIds_Rx.add(word.wordId);
    }
  }

  /// Add record to reviewedWordHistory, won't overwrite it
  void addWordReviewedHistory(Word word,
      {WordMemoryStatus status = WordMemoryStatus.NORMAL}) {
    // If have history, change it to not latest
    var relatedWordHistory = userWordsHistory_Rx
        .filter((history) => history.wordId == word.wordId && history.isLatest);
    if (relatedWordHistory.length == 1) {
      relatedWordHistory.single.isLatest = false;
    }
    userWordsHistory_Rx.add(WordHistory(
        wordId: word.wordId,
        wordMemoryStatus: status,
        timestamp: Timestamp.now(),
        isLatest: true));
  }

  /// Add record to reviewedClassHistory, won't overwrite it
  void addLectureReviewedHistory(Lecture lecture) {
    // If have history, change it to not latest
    var relatedClassHistory = userLecturesHistory_Rx.filter((history) =>
        history.lectureId == lecture.lectureId && history.isLatest);
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
    UserService.user
      ..likedWords = userLikedWordIds_Rx.toList()
      ..reviewedClassHistory = userLecturesHistory_Rx.toList()
      ..reviewedWordHistory = userWordsHistory_Rx.toList();
    UserService.commitChange();
  }

  /// Show a single word card from dialog
  void showSingleWordCard(Word word) {
    Get.dialog(
      SimpleDialog(
        children: [WordCard(word: word)],
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
      barrierColor: Get.isDialogOpen ? Colors.transparent : null,
    );
  }
}
