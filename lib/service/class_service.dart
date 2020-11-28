import 'package:get/get.dart';
import 'package:supercharged/supercharged.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:spoken_chinese/app/models/class.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'api_service.dart';

/*
* This class provide service related to Class, like fetching class,
* words, etc.
*/
class ClassService extends GetxService {
  static ClassService _instance;
  static final ApiService _apiService = Get.find();
  static List<CSchoolClass> allClasses;
  static List<Word> allWords;

  static Future<ClassService> getInstance() async {
    if (_instance.isNull) {
      _instance ??= ClassService();
      allWords = await _apiService.firestoreApi.fetchWords();
      allClasses = await _apiService.firestoreApi.fetchClasses();
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
  //TODO: implement those
  WordStatus getStausOfWord(Word word) {}

  bool isWordLiked(Word word) {}

  int wordViewedCount(Word word) {}

  int classViewedCount(CSchoolClass cSchoolClass){

  }
}
