import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/service/app_state_service.dart';
import 'package:c_school_app/service/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:supercharged/supercharged.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/model/user_word_history.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/controller/ui_view_controller/word_card_controller.dart';
import 'package:c_school_app/service/logger_service.dart';
import 'package:c_school_app/controller/trackable_controller_interface.dart';
import 'review_words_controller_track.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController
    with SingleGetTickerProviderMixin
    implements TrackableController {
  final LectureService lectureService = Get.find();
  final logger = LoggerService.logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  PageController pageController;
  AnimationController searchBarPlayIconController;

  /// Current primary word ordinal in _wordList
  final primaryWordIndex = 0.obs;

  /// List or card
  final _mode = WordsReviewMode.LIST.obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Controller for words list
  final groupedItemScrollController = GroupedItemScrollController();

  /// WordsHistory of this user
  RxList<WordHistory> _userWordsHistory;

  /// If all words mode, there will be multiple lectures associated
  List<Lecture> lectures;

  /// WordsList for this lecture(s)
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
    _userWordsHistory = LectureService.userWordsHistory_Rx;
    lectures = lectureService.findLecturesById(Get.parameters['lectureId']);
    if (Get.arguments == null) {
      wordsList = lectures.length == 1
          ? lectures.single.words
          : LectureService.allWords;
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
    // worker to update track whenever it change
    ever(primaryWordIndex, (_) => updateTrack());
    // If is a specific lecture, add it to history
    if (lectures.length == 1) {
      lectureService.addLectureReviewedHistory(lectures.single);
    }
    if (AppStateService.isDebug) {
      AudioPlayer.logEnabled = true;
    }
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value;

  /// PrimaryWord associated with primaryWordIndex
  Word get primaryWord => reversedWordsList[primaryWordIndex.value];

  WordCardController get primaryWordCardController =>
      Get.find(tag: primaryWord.wordId);

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
    lectureService.addWordReviewedHistory(word, status: wordMemoryStatus.value);
    wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
  }

  /// Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if(primaryWordCardController.isCardFlipped.isTrue) {
      primaryWordCardController.flipCard();
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
        _animateToWordById(controllerTrack.trackedWordId);
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
    word ??= primaryWord;
    var wordAudio = word.wordAudioMale;
    if (wordAudio == null) {
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
      await _animateToFirstWord();
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
      await Timer(0.5.seconds, primaryWordCardController.flipCard);
      await Timer(0.5.seconds, () async {
        if (!isAutoPlayMode.value) return;
        await primaryWordCardController.playWord(completionCallBack: () async {
          // after playWord
          // When we reach the last card or autoPlay turn off
          if (!isAutoPlayMode.value || primaryWordIndex.value == 0) {
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
    lectureService.showSingleWordCard(word);
  }

  /// Search card content, consider a match if word or meaning contains query
  void search() {
    if (isAutoPlayMode.value) return;
    if (searchQuery.value.isBlank) {
      searchResult.clear();
      return;
    }
    var containKeyWord = (Word word) {
      return word.wordAsString.contains(searchQuery.value) ||
          word.wordMeanings.any((m) =>
              m.meaning.contains(searchQuery.value) ||
              word.tags.contains(searchQuery.value));
    };
    searchResult.clear();
    searchResult.addAll(wordsList.filter((word) => containKeyWord(word)));
  }

  Future<void> _animateToFirstWord() async {
    await pageController.animateToPage(pageController.initialPage,
        duration: 0.5.seconds, curve: Curves.easeInOut);
  }

  /// If we didn't find word id or its null, will go to first word
  Future<void> _animateToWordById(String wordId) async {
    var index = wordsList.indexWhere((word) => word.wordId == wordId);
    // If couldn't find the wordId, go to first word
    if (index == -1) {
      await _animateToFirstWord();
    } else {
      await pageController.animateToPage(index,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
  }

  int indexOfWord(Word word) => wordsList.indexOf(word);

  @override
  void updateTrack() {
    controllerTrack.trackedWordId = primaryWord.wordId;
  }

  @override
  ReviewWordsControllerTrack get controllerTrack =>
      UserService.user.getControllerTrack<ReviewWordsControllerTrack>() ??
      ReviewWordsControllerTrack();

  @override
  void onClose() {
    // If we have are at last card, clear track
    if (primaryWordIndex.value == wordsList.length - 1) {
      controllerTrack.trackedWordId = null;
    }
    lectureService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }
}

enum WordsReviewMode { LIST, FLASH_CARD }
