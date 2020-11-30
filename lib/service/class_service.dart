import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:c_school_app/model/user_class_history.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:supercharged/supercharged.dart';
import 'package:c_school_app/app/models/class.dart';
import 'package:c_school_app/app/models/word.dart';
import 'api_service.dart';
import '../model/user.dart';

/*
* This class provide service related to Class, like fetching class,
* words, etc.
*/
class ClassService extends GetxService {
  static ClassService _instance;
  static final ApiService _apiService = Get.find();
  /// All classes available
  static List<CSchoolClass> allClasses;
  /// All words available
  static List<Word> allWords;

  /// Observable Liked words list for updating
  static RxList<String> userLikedWordIds_Rx;
  /// Observable Class History list for updating
  static RxList<ClassHistory> userClassesHistory_Rx;
  /// Observable Word History list for updating
  static RxList<WordHistory> userWordsHistory_Rx;
  static Future<ClassService> getInstance() async {
    if (_instance.isNull) {
      _instance ??= ClassService();
      /// All available words
      allWords = await _apiService.firestoreApi.fetchWords();
      /// All available Classes
      allClasses = await _apiService.firestoreApi.fetchClasses();
      /// This properties need to be observable and can be use to update AppUser
      userLikedWordIds_Rx = List<String>.of(UserService.user.likedWords).obs;
      /// This properties need to be observable and can be use to update AppUser
      userClassesHistory_Rx = (List<ClassHistory>.of(UserService.user.reviewedClassHistory)).obs;
      /// This properties need to be observable and can be use to update AppUser
      userWordsHistory_Rx = (List<WordHistory>.of(UserService.user.reviewedWordHistory)).obs;
    }

    return _instance;
  }

  /// If id is empty , get all
  List<Word> findWordsByIds(List<String> ids) {
    if (ids.isNullOrBlank) {
      return allWords;
    } else {
      return allWords.filter((word) => ids.contains(word.wordId)).toList();
    }
  }

  /// If id is empty , get all
  List<Word> findWordsByTags(List<WordTag> tags) {
    if (tags.isNullOrBlank) {
      return allWords;
    } else {
      return allWords
          .filter((word) => tags.every((tag) => word.tags.contains(tag)))
          .toList();
    }
  }

  /// If id is empty , get all
  List<CSchoolClass> findClassesById(String id) {
    if (id.isNullOrBlank) {
      return allClasses;
    } else {
      return [
        allClasses.filter((cschoolClass) => id == cschoolClass.classId).single
      ];
    }
  }

  /// If id is empty , get all
  List<CSchoolClass> findClassesByTags(List<ClassTag> tags) {
    if (tags.isNullOrBlank) {
      return allClasses;
    } else {
      return allClasses
          .filter((cschoolClass) =>
              tags.every((tag) => cschoolClass.tags.contains(tag)))
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
  int classViewedCount(CSchoolClass cschoolClass) =>
      UserService.user.reviewedClassHistory
          .filter((record) => record.classId == cschoolClass.classId)
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
  void addClassReviewedHistory(CSchoolClass cschoolClass) {
    // If have history, change it to not latest
    var relatedClassHistory = userClassesHistory_Rx
        .filter((history) =>
            history.classId == cschoolClass.classId && history.isLatest);
    if(relatedClassHistory.length==1){
      relatedClassHistory.single.isLatest =false;
    }
    userClassesHistory_Rx.add(ClassHistory(
        classId: cschoolClass.classId,
        timestamp: Timestamp.now(),
        isLatest: true));
  }

  /// Commit any changed made to _appUserForUpdate
  void commitChange() {
    UserService.user
      ..likedWords = userLikedWordIds_Rx.toList()
      ..reviewedClassHistory = userClassesHistory_Rx.toList()
      ..reviewedWordHistory = userWordsHistory_Rx.toList();
    UserService.commitChange();
  }
}
