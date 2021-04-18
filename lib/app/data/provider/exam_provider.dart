// 📦 Package imports:
import 'package:flamingo/flamingo.dart';

// 🌎 Project imports:
import '../model/exam/exam_base.dart';

abstract class ExamProvider {
  Future<List<Exam>> get({List<String>? tags});
}

class ExamFirebaseProvider implements ExamProvider {
  @override
  Future<List<Exam>> get({List<String>? tags}) async {
    final collectionPaging = CollectionPaging<Exam>(
      query: Exam().collectionRef.orderBy('examId'),
      limit: 10000,
      decode: (snap) => Exam.fromSnapshot(snap), // don't use Exam()
    );
    return await collectionPaging.load();
  }
}
