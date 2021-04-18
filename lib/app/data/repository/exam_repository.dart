// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../core/utils/index.dart';
import '../model/exam/exam_base.dart';
import '../provider/exam_provider.dart';

class ExamRepository extends GetxService {
  static ExamRepository? _instance;
  final ExamProvider _provider = ExamFirebaseProvider();
  late List<Exam> _allExams;

  ExamRepository._internal();

  static Future<ExamRepository> get instance async {
    if (_instance == null) {
      _instance ??= ExamRepository._internal();
      _instance!._allExams = await _instance!._provider.get();
    }
    return _instance!;
  }

  Future<void> refresh() async => _allExams = await _provider.get();

  List<Exam> get allExams => _allExams;

  List<Exam> findExamBy(Map<String, dynamic> conditions) =>
      _allExams.filter(conditions);
}
