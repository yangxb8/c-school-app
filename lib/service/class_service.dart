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

  List<Word> findWordsByIds(List<String> ids) {
    return allWords.filter((word) => ids.contains(word.wordId)).toList();
  }

  List<Word> findWordsByTags(List<WordTag> tags) {
    return allWords
        .filter((word) => tags.every(
            (tag) => word.tags.contains(EnumToString.convertToString(tag))))
        .toList();
  }
}
