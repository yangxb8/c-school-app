// 📦 Package imports:
import 'package:flamingo/flamingo.dart';

// 🌎 Project imports:
import '../model/lecture.dart';

abstract class LectureProvider {
  Future<List<Lecture>> get({List<String>? tags});
}

class LectureFirebaseProvider implements LectureProvider {
  @override
  Future<List<Lecture>> get({List<String>? tags}) async {
    final collectionPaging = CollectionPaging<Lecture>(
      query: Lecture().collectionRef.orderBy('lectureId'),
      limit: 10000,
      decode: (snap) => Lecture(snapshot: snap),
    );
    return await collectionPaging.load();
  }
}
