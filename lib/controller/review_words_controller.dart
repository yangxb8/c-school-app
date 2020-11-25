import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:supercharged/supercharged.dart';
import 'package:spoken_chinese/app/review_panel/ui_view/words_list.dart';
import 'package:spoken_chinese/model/user.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'package:spoken_chinese/service/api_service.dart';
import 'package:spoken_chinese/service/logger_service.dart';

class ReviewWordsController extends GetxController {
  /// Current primary word ordinal in _wordList
  final primaryWordOrdinal = 0.obs;

  /// List or card
  final _mode = _WordsReviewModeWrapper().obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Words user favorite
  final _userSavedWordsID =
      (AppUser.userGeneratedData['savedWordsID'] as List).obs;

  /// Total words list
  List<Word> wordsList = [];
  final apiService = Get.find<ApiService>();
  final logger = Get.find<LoggerService>().logger;
  final tts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();

  Future<void> fetchWordsAndInitByTags(List<String> tags) async {
    //TODO: Test data, replace me
    var word1 = Word(id: 'C0001-0001');
    word1
      ..word = ['我', '们']
      ..pinyin = ['wo', 'men']
      ..meaningJp = ['私達']
      ..examples = {
        '私達': ['我们都是好学生。', '我们都是好战士']
      }
      ..relatedWordIDs = ['C0001-0002'];
    var word2 = Word(id: 'C0001-0002');
    word2
      ..word = ['都', '是']
      ..pinyin = ['dou', 'shi']
      ..meaningJp = ['は..だ']
      ..examples = {
        'は..だ': ['我们都是猪。', '你才是猪']
      };
    var temp_wordList = [
      word1,
      word2,
      word1,
      word2,
      word1,
      word2,
      word1,
      word2,
      word1,
      word2,
      word1,
      word2
    ];
    wordsList = List.from(temp_wordList.reversed);
    await tts.setLanguage('zh-cn');
    await tts.setSpeechRate(0.5);
  }

  WordsReviewMode get mode => _mode.value.wordsReviewMode;
  Word get primaryWord => wordsList[primaryWordOrdinal.value];
  String get primaryWordString => primaryWord.word.join();
  bool get isFavorite => _userSavedWordsID.contains(primaryWord.id);
  List<WordsSection> get sectionList {
    var sectionList_ = <WordsSection>[];
    // Get class id from wordId, and use classId to group words
    wordsList.groupBy((word) => word.id.split('-').first).forEach((key, value) {
      var section = WordsSection();
      section
        ..expanded = true
        ..items = value;
      sectionList_.add(section);
    });
    return sectionList_;
  }

  void toggleFavorite() {
    if (isFavorite) {
      _userSavedWordsID.remove(primaryWord.id);
    } else {
      _userSavedWordsID.add(primaryWord.id);
    }
  }

  void changeMode() {
    if (_mode.value.wordsReviewMode == WordsReviewMode.FLASH_CARD) {
      _mode.update((mode) => mode.wordsReviewMode = WordsReviewMode.LIST);
      logger.i('Change to List Mode');
    } else {
      _mode.update((mode) => mode.wordsReviewMode = WordsReviewMode.FLASH_CARD);
      logger.i('Change to Card Mode');
    }
  }

  /// Play audio of the word
  Future<void> playWord({Word word}) async {
    if (word.isNull) word = primaryWord;
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      await tts.speak(word.word.join());
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  /// Play audio of the examples
  Future<void> playExample(
      {@required String meaning, @required String sentence}) async {
    var exampleOrdinal = primaryWord.examples[meaning]?.indexOf(sentence);
    var audioFileList = primaryWord.examplesAudio[meaning];
    if (audioFileList.isNull || audioFileList[exampleOrdinal].isNull) {
      await tts.speak(sentence);
    } else {
      await audioPlayer.play(audioFileList[exampleOrdinal].url);
    }
  }

  List<String> findRelatedWord() {
    //TODO: implement this
  }

  // TODO: implement this. we should save liked, smile, sad, viewed words
  @override
  void onClose() {
    super.onClose();
  }
}

class _WordsReviewModeWrapper {
  var wordsReviewMode = WordsReviewMode.LIST;
}

enum WordsReviewMode { LIST, FLASH_CARD }
