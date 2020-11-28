import 'package:audioplayers/audioplayers.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spoken_chinese/app/models/class.dart';
import 'package:spoken_chinese/service/class_service.dart';
import 'package:spoken_chinese/app/review_panel/review_words_screen//ui_view/words_list.dart';
import 'package:spoken_chinese/model/user.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'package:spoken_chinese/service/logger_service.dart';
import 'package:spoken_chinese/service/user_service.dart';

class ReviewWordsController extends GetxController {
  /// Current primary word ordinal in _wordList
  final primaryWordOrdinal = 0.obs;

  /// List or card
  final _mode = _WordsReviewModeWrapper().obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Words user favorite
  final _userSavedWordsID =
      (UserService.user.savedWords).obs;

  List<CSchoolClass> classes;
  List<Word> wordsList = [];
  final logger = Get.find<LoggerService>().logger;
  final ClassService classService = Get.find();
  final tts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    // wordsList = List.from(classService.findWordsByTags(tags).reversed);
    classes = classService.findClassesById(Get.parameters['classId']);
    wordsList = classes.length == 1
        ? List.from(classes.single.words.reversed)
        : ClassService.allWords;
    await tts.setLanguage('zh-cn');
    await tts.setSpeechRate(0.5);
    super.onInit();
  }

  WordsReviewMode get mode => _mode.value.wordsReviewMode;
  Word get primaryWord => wordsList[primaryWordOrdinal.value];
  String get primaryWordString => primaryWord.word.join();
  bool get isFavorite => _userSavedWordsID.contains(primaryWord.id);
  List<WordsSection> get sectionList {
    var sectionList_ = <WordsSection>[];
    // Get class id from wordId, and use classId to group words
    classes.forEach((cschoolClass) {
      var section = WordsSection();
      section
        ..expanded = true
        ..header = cschoolClass.title
        ..items = cschoolClass.words;
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
      {@required String string, @required StorageFile audio}) async {
    if (audio.isNull) {
      await tts.speak(string);
    } else {
      await audioPlayer.play(audio.url);
    }
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
