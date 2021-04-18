// 📦 Package imports:
import 'package:flamingo/flamingo.dart';

// 🌎 Project imports:
import '../model/word/word.dart';

abstract class WordProvider {
  Future<List<Word>> get({List<String>? tags});
}

class WordFirebaseProvider implements WordProvider {
  @override
  Future<List<Word>> get({List<String>? tags}) async {
    final collectionPaging = CollectionPaging<Word>(
      query: Word().collectionRef.orderBy('wordId'),
      limit: 10000,
      decode: (snap) => Word(snapshot: snap),
    );
    return await collectionPaging.load();
  }
}
