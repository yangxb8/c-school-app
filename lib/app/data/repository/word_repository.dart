// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../core/utils/index.dart';
import '../model/word/word.dart';
import '../provider/word_provider.dart';

/// Initialize at start of app and cache all words.
class WordRepository extends GetxService {
  WordRepository._internal();

  static WordRepository? _instance;

  late List<Word> _allWords;
  final WordProvider _provider = WordFirebaseProvider();

  static Future<WordRepository> get instance async {
    if (_instance == null) {
      _instance ??= WordRepository._internal();
      _instance!._allWords = await _instance!._provider.get();
    }
    return _instance!;
  }

  Future<void> refresh() async => _allWords = await _provider.get();

  List<Word> get allWords => _allWords;

  List<Word> findWordBy(Map<String, dynamic> conditions) =>
      _allWords.filter(conditions);
}
