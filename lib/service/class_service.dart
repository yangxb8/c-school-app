import 'package:get/get.dart';
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
  static List<CSchoolClass> _allClasses;
  static List<Word> _allWords;

  static ClassService getInstance() {
    _instance ??= ClassService();
    return _instance;
  }

  Future<List<CSchoolClass>> get allClasses async{
    _allClasses ??= await _apiService.firestoreApi.fetchClasses();
    return _allClasses;
  }

  Future<List<Word>> get allWords async{
    _allWords ??= await _apiService.firestoreApi.fetchWords();
    return _allWords;
  }
}
