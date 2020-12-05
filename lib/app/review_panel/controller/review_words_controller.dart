import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:c_school_app/app/ui_view/word_card.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/models/class.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:c_school_app/app/review_panel/review_words_screen//ui_view/words_list.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController {
  final ClassService classService = Get.find();
  final logger = Get.find<LoggerService>().logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  PageController pageController;

  /// Current primary word ordinal in _wordList
  final primaryWordOrdinal = 0.obs;

  /// List or card
  final _mode = WordsReviewMode.LIST.obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// WordsHistory of this user
  RxList<WordHistory> _userWordsHistory;

  /// If all words mode, there will be multiple classes associated
  List<CSchoolClass> classes;

  /// WordsList for this class(es)
  List<Word> wordsList = [];

  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  /// Used to controller pagination of card
  RxDouble pageFraction;

  var isFirstPage;

  var isLastPage;

  RxBool isAutoPlayMode = false.obs;

  /// Null Timer means we are not in autoPlay mode
  Timer _autoPlayTimer;

  RxString searchQuery = ''.obs;

  RxList<Word> searchResult = <Word>[].obs;

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    _userWordsHistory = ClassService.userWordsHistory_Rx;
    classes = classService.findClassesById(Get.parameters['classId']);
    wordsList = classes.length == 1
        ? List.from(classes.single.words.reversed)
        : List.from(ClassService.allWords.reversed);
    pageFraction = (wordsList.length - 1.0).obs;
    pageController = PageController(initialPage: wordsList.length - 1);
    await tts.setLanguage(LAN_CODE_CN);
    await tts.setSpeechRate(0.5);
    // worker to monitor search query change and fire search function
    debounce(searchQuery, (_) => search(), time: Duration(seconds: 1));
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value;

  /// PrimaryWord associated with primaryWordOrdinal
  Word get primaryWord => wordsList[primaryWordOrdinal.value];

  WordCardController get primaryWordCardController =>
      Get.find(tag: primaryWord.wordId);

  /// PrimaryWord.word to String for display
  String get primaryWordString => primaryWord.word.join();

  int countWordMemoryStatusOfWordByStatus(
          {@required WordMemoryStatus status}) =>
      _userWordsHistory
          .filter((history) =>
              history.wordId == primaryWord.wordId &&
              history.wordMemoryStatus == status)
          .length;

  void handWordMemoryStatusPressed(WordMemoryStatus status) {
    if (wordMemoryStatus.value == status) {
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    } else {
      wordMemoryStatus.value = status;
    }
  }

  /// If nothing is pressed, default to NORMAL
  void saveAndResetWordHistory(Word word) {
    if (wordMemoryStatus.value == WordMemoryStatus.NOT_REVIEWED) {
      wordMemoryStatus.value = WordMemoryStatus.NORMAL;
    }
    classService.addWordReviewedHistory(word, status: wordMemoryStatus.value);
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

  void notifyPageChanged(int page) {
    isLastPage = page + 1 == wordsList.length;
    isFirstPage = page == 0;
  }

  /// Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if (!primaryWordCardController.flipController.isFront) {
      primaryWordCardController.flipController.flip();
    }
  }

  /// In autoPlay, user is restricted to card mode, this might need to be changed for better UX
  void changeMode() {
    if (isAutoPlayMode.value) return;
    if (_mode.value == WordsReviewMode.FLASH_CARD) {
      _mode.value = WordsReviewMode.LIST;
      logger.i('Change to List Mode');
    } else {
      _mode.value = WordsReviewMode.FLASH_CARD;
      logger.i('Change to Card Mode');
    }
  }

  /// Play audio of the word
  Future<void> playWord({Word word}) async {
    if (word.isNull) word = primaryWord;
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  void autoPlayPressed() async {
    // If already in autoPlay mode
    if (isAutoPlayMode.value) {
      _autoPlayTimer.cancel();
      _autoPlayTimer = null;
    } else {
      // Force using card mode
      if (_mode.value == WordsReviewMode.LIST) {
        changeMode();
      }
      // Play from beginning
      await pageController.animateToPage(pageController.initialPage,
          duration: 2.seconds, curve: Curves.bounceInOut);
      _autoPlayTimer = Timer.periodic(2.seconds, (_) async {
        // When user press button or we reach last card
        if (!isAutoPlayMode.value ||
            primaryWordOrdinal.value == wordsList.lastIndex) {
          _autoPlayTimer.cancel();
          _autoPlayTimer = null;
          return;
        }
        await Timer(500.milliseconds,
            () async => await primaryWordCardController.playMeaning());
        flipBackPrimaryCard();
        await Timer(500.milliseconds,
            () async => await primaryWordCardController.playWord());
        await pageController.nextPage(
            duration: 300.milliseconds, curve: Curves.easeInOut);
      });
    }
    isAutoPlayMode.value = !isAutoPlayMode.value;
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    showDialog<void>(
        context: Get.context,
        builder: (context) => SimpleDialog(
              children: [WordCard(word: word)],
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
            ));
  }

  /// Search card content, consider a match if word or meaning contains query
  void search() {
    var containKeyWord = (Word word) {
      return word.wordAsString.contains(searchQuery.value) ||
          word.wordMeanings.any((m) => m.meaning.contains(searchQuery.value));
    };
    searchResult.clear();
    searchResult.addAll(wordsList.filter((word) => containKeyWord(word)));
  }

  @override
  void onClose() {
    classService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }
}

enum WordsReviewMode { LIST, FLASH_CARD }
