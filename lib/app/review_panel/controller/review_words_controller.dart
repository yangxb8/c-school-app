import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/app/ui_view/word_card.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/models/class.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController
    with SingleGetTickerProviderMixin {
  final ClassService classService = Get.find();
  final logger = LoggerService.logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  PageController pageController;
  AnimationController searchBarPlayIconController;

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

  /// Reversed Words List for flashCard
  List<Word> reversedWordsList = [];

  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  /// Used to controller pagination of card
  RxDouble pageFraction;

  RxBool isAutoPlayMode = false.obs;

  RxString searchQuery = ''.obs;

  RxList<Word> searchResult = <Word>[].obs;

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    _userWordsHistory = ClassService.userWordsHistory_Rx;
    classes = classService.findClassesById(Get.parameters['classId']);
    if (Get.arguments == null) {
      wordsList =
          classes.length == 1 ? classes.single.words : ClassService.allWords;
      // If wordsList is provided, use it
    } else if (Get.arguments is List<Word>) {
      wordsList = Get.arguments;
    }
    reversedWordsList = wordsList.reversed.toList();
    pageFraction = (wordsList.length - 1.0).obs;
    pageController = PageController(initialPage: wordsList.length - 1);
    searchBarPlayIconController =
        AnimationController(vsync: this, duration: 0.3.seconds);
    await tts.setLanguage(LAN_CODE_CN);
    await tts.setSpeechRate(0.5);
    // worker to monitor search query change and fire search function
    debounce(searchQuery, (_) => search(), time: Duration(seconds: 1));
    // If is a specific class, add it to history
    if (classes.length == 1) {
      classService.addClassReviewedHistory(classes.single);
    }
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value;

  /// PrimaryWord associated with primaryWordOrdinal
  Word get primaryWord => reversedWordsList[primaryWordOrdinal.value];

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

  /// Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if (!primaryWordCardController.flipController.isFront) {
      primaryWordCardController.flipController.flip();
    }
  }

  /// In autoPlay, user is restricted to card mode, this might need to be changed for better UX
  void changeMode() {
    // If in autoPlay mode, stop it
    if (isAutoPlayMode.value) {
      isAutoPlayMode.value = false;
    }
    if (_mode.value == WordsReviewMode.FLASH_CARD) {
      _mode.value = WordsReviewMode.LIST;
      logger.i('Change to List Mode');
    } else {
      _mode.value = WordsReviewMode.FLASH_CARD;
      if (pageController.hasClients) {
        _animateToFirstPage();
      }
      logger.i('Change to Card Mode');
    }
  }

  /// Simplified version of same method in WordCard
  /// As we might need to play from word list.
  ///
  /// Play audio of the word
  Future<void> playWord({Word word}) async {
    if (isAutoPlayMode.value) return;
    if (word.isNull) word = primaryWord;
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  /// Handle autoPlay button pressed, will start play in card mode from beginning.
  /// Or, if already in autoPlay mode, cancel it.
  void autoPlayPressed() async {
    // Force using card mode
    if (_mode.value == WordsReviewMode.LIST) {
      changeMode();
      // For re-render to happen, we set a timer and return from this call
      Timer(0.3.seconds, () => autoPlayPressed());
      return;
    }
    if (!isAutoPlayMode.value) {
      searchBarPlayIconController.forward();
      isAutoPlayMode.value = true;
      // Play from beginning
      await _animateToFirstPage();
      flipBackPrimaryCard();
      _autoPlayCard();
    } else {
      searchBarPlayIconController.reverse();
      isAutoPlayMode.value = false;
    }
  }

  /// Tts package use listener to handler completion of speech
  /// So we need to set logic after each tts speech inside a
  /// callback function
  ///
  /// Also, we check isAutoPlayMode in multiple stage so user
  /// can stop the play anytime
  void _autoPlayCard() async {
    if (!isAutoPlayMode.value) return;
    await primaryWordCardController.playMeanings(completionCallBack: () async {
      // after playMeanings
      if (!isAutoPlayMode.value) return;
      await Timer(0.5.seconds, primaryWordCardController.flipController.flip);
      await Timer(0.5.seconds, () async {
        if (!isAutoPlayMode.value) return;
        await primaryWordCardController.playWord(completionCallBack: () async {
          // after playWord
          // When we reach the last card or autoPlay turn off
          if (!isAutoPlayMode.value || primaryWordOrdinal.value == 0) {
            searchBarPlayIconController.reverse();
            isAutoPlayMode.value = false;
          } else {
            await pageController.previousPage(
                duration: 300.milliseconds, curve: Curves.easeInOut);
            Future.delayed(1.seconds, _autoPlayCard);
          }
        });
      });
    });
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    Get.dialog(
      SimpleDialog(
        children: [WordCard(word: word)],
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
      barrierColor: Get.isDialogOpen ? Colors.transparent : null,
    );
  }

  /// Search card content, consider a match if word or meaning contains query
  void search() {
    if (isAutoPlayMode.value) return;
    if (searchQuery.value.isNullOrBlank) {
      searchResult.clear();
      return;
    }
    var containKeyWord = (Word word) {
      return word.wordAsString.contains(searchQuery.value) ||
          word.wordMeanings.any((m) => m.meaning.contains(searchQuery.value));
    };
    searchResult.clear();
    searchResult.addAll(wordsList.filter((word) => containKeyWord(word)));
  }

  Future _animateToFirstPage() async {
    await pageController.animateToPage(pageController.initialPage,
        duration: 0.5.seconds, curve: Curves.easeInOut);
  }

  @override
  void onClose() {
    classService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }

  int calculateWordIndex(Word word) => wordsList.indexOf(word);
}

enum WordsReviewMode { LIST, FLASH_CARD }
