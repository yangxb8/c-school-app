import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spoken_chinese/app/models/class.dart';
import 'package:spoken_chinese/model/user_word_history.dart';
import 'package:spoken_chinese/service/class_service.dart';
import 'package:spoken_chinese/app/review_panel/review_words_screen//ui_view/words_list.dart';
import 'package:spoken_chinese/app/models/word.dart';
import 'package:spoken_chinese/service/logger_service.dart';

class ReviewWordsController extends GetxController {
  final ClassService classService = Get.find();
  final logger = Get.find<LoggerService>().logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  /// Current primary word ordinal in _wordList
  final primaryWordOrdinal = 0.obs;

  /// List or card
  final _mode = _WordsReviewModeWrapper().obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Words user favorite
  RxList<String> _userLikedWordIds;

  /// WordsHistory of this user
  RxList<WordHistory> _userWordsHistory;

  /// If all words mode, there will be multiple classes associated
  List<CSchoolClass> classes;

  /// WordsList for this class(es)
  List<Word> wordsList = [];

  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    // wordsList = List.from(classService.findWordsByTags(tags).reversed);
    _userLikedWordIds = ClassService.userLikedWordIds_Rx;
    _userWordsHistory = ClassService.userWordsHistory_Rx;
    classes = classService.findClassesById(Get.parameters['classId']);
    wordsList = classes.length == 1
        ? List.from(classes.single.words.reversed)
        : ClassService.allWords;
    await tts.setLanguage('zh-cn');
    await tts.setSpeechRate(0.5);
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value.wordsReviewMode;

  /// PrimaryWord associated with primaryWordOrdinal
  Word get primaryWord => wordsList[primaryWordOrdinal.value];

  /// PrimaryWord.word to String for display
  String get primaryWordString => primaryWord.word.join();

  /// If primary word is liked by user
  bool get isPrimaryWordLiked => _userLikedWordIds.contains(primaryWord.id);

  void toggleFavoriteCard(int cardOrdinal) =>
      classService.toggleWordLiked(wordsList[cardOrdinal]);

  int countWordMemoryStatusOfWordByStatus(
          {@required WordMemoryStatus status}) =>
      _userWordsHistory
          .filter((history) =>
              history.wordId == primaryWord.wordId &&
              history.wordMemoryStatus == status)
          .length;

  /// Return value is defined by like_button package
  Future<bool> handleRememberPressed(bool isLiked) {
    if (isLiked) {
      _handWordMemoryStatusPressed(WordMemoryStatus.REMEMBERED);
    } else {
      _handWordMemoryStatusPressed(WordMemoryStatus.NOT_REVIEWED);
    }
    return Future.value(true);
  }

  /// Return value is defined by like_button package
  Future<bool> handleNormalPressed(bool isLiked) {
    if (isLiked) {
      _handWordMemoryStatusPressed(WordMemoryStatus.NORMAL);
    } else {
      _handWordMemoryStatusPressed(WordMemoryStatus.NOT_REVIEWED);
    }
    return Future.value(true);
  }

  /// Return value is defined by like_button package
  Future<bool> handleForgotPressed(bool isLiked) {
    if (isLiked) {
      _handWordMemoryStatusPressed(WordMemoryStatus.FORGOT);
    } else {
      _handWordMemoryStatusPressed(WordMemoryStatus.NOT_REVIEWED);
    }
    return Future.value(true);
  }

  void _handWordMemoryStatusPressed(WordMemoryStatus status) {
    wordMemoryStatus.value = status;
  }

  /// If nothing is pressed, default to NORMAL
  void saveAndResetWordHistory() {
    if (wordMemoryStatus.value == WordMemoryStatus.NOT_REVIEWED) {
      wordMemoryStatus.value = WordMemoryStatus.NORMAL;
    }
    classService.addWordReviewedHistory(primaryWord,
        status: wordMemoryStatus.value);
    wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
  }

  /// Sections for words list
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

  @override
  void onClose() {
    classService.commitChange();
    super.onClose();
  }
}

class _WordsReviewModeWrapper {
  var wordsReviewMode = WordsReviewMode.LIST;
}

enum WordsReviewMode { LIST, FLASH_CARD }
