// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../core/utils/index.dart';
import '../model/lecture.dart';
import '../provider/lecture_provider.dart';

/// Initialize at start of app and cache all lectures.
class LectureRepository extends GetxService {
  LectureRepository._internal();

  static LectureRepository? _instance;

  late List<Lecture> _allLectures;
  final LectureProvider _provider = LectureFirebaseProvider();

  static Future<LectureRepository> get instance async {
    if (_instance == null) {
      _instance ??= LectureRepository._internal();
      _instance!._allLectures = await _instance!._provider.get();
    }
    return _instance!;
  }

  Future<void> refresh() async => _allLectures = await _provider.get();

  List<Lecture> get allLectures => _allLectures;

  List<Lecture> findLectureBy(Map<String, dynamic> conditions) =>
      _allLectures.filter(conditions);
}
