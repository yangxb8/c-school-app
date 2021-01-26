import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/service/app_state_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
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
import '../../../util/extensions.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController
    with SingleGetTickerProviderMixin {
  final LectureService lectureService = Get.find();
  final logger = LoggerService.logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  PageController pageController;
  /// Animate icon
  AnimationController searchBarPlayIconController;
  /// Animate icon color
  Rx<CustomAnimationControl> searchBarPlayIconControl = CustomAnimationControl.STOP.obs;

  /// Key for primaryWordIndex
  static const primaryWordIndexKey = 'ReviewWordsController.primaryWordIndex';

  /// Current primary word ordinal in _wordList
  final primaryWordIndex = 0.obs;

  /// Controller of primary card
  WordCardController primaryWordCardController;

  /// List or card
  final _mode = WordsReviewMode.list.obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Controller for words list
  final groupedItemScrollController = GroupedItemScrollController();

  /// If word list is first time rendered, special animation will be shown
  bool isListFirstRender = true;

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

  Rx<SpeakerGender> speakerGender = SpeakerGender.male.obs;

  @override
  Future<void> onInit() async {
    // As our cards are stack from bottom to top, reverse the words order
    _userWordsHistory = LectureService.userWordsHistory_Rx;
    lectures = [lectureService.findLectureById(Get.parameters['lectureId'])];
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

  /// Save status to history
  void saveAndResetWordHistory(Word word) {
    if (wordMemoryStatus.value != WordMemoryStatus.NOT_REVIEWED) {
      lectureService.addWordReviewedHistory(word,
          status: wordMemoryStatus.value);
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    }
  }

  /// Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if (primaryWordCardController.isCardFlipped.isTrue) {
      primaryWordCardController.flipCard();
    }
  }

  /// In autoPlay, user is restricted to card mode, this might need to be changed for better UX
  void changeMode() {
    // If in autoPlay mode, stop it
    if (isAutoPlayMode.value) {
      isAutoPlayMode.value = false;
    }
    if (_mode.value == WordsReviewMode.flash_card) {
      _mode.value = WordsReviewMode.list;
      logger.i('Change to List Mode');
    } else {
      _mode.value = WordsReviewMode.flash_card;
      logger.i('Change to Card Mode');
    }
  }

  /// Male or Female
  void toggleSpeakerGender() {
    speakerGender.value = speakerGender.value == SpeakerGender.male
        ? SpeakerGender.female
        : SpeakerGender.male;
  }

  /// Simplified version of same method in WordCard
  /// As we might need to play from word list.
  ///
  /// Play audio of the word
  Future<void> playWord({Word word}) async {
    if (isAutoPlayMode.value) return;
    word ??= primaryWord;
    var wordAudio = speakerGender.value == SpeakerGender.male
        ? word.wordAudioMale
        : word.wordAudioFemale;
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
    if (_mode.value == WordsReviewMode.list) {
      changeMode();
      // For re-render to happen, we set a timer and return from this call
      Timer(0.3.seconds, () => autoPlayPressed());
      return;
    }
    if (!isAutoPlayMode.value) {
      searchBarPlayIconController.forward();
      searchBarPlayIconControl.value=CustomAnimationControl.PLAY_FROM_START;
      isAutoPlayMode.value = true;
      // Play from beginning
      await _animateToFirstWord();
      flipBackPrimaryCard();
      _autoPlayCard();
    } else {
      searchBarPlayIconController.reverse();
      searchBarPlayIconControl.value=CustomAnimationControl.PLAY_REVERSE_FROM_END;
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
    if (isAutoPlayMode.isfalse) return;
    await primaryWordCardController.playMeanings(completionCallBack: () async {
      // after playMeanings
      if (isAutoPlayMode.isfalse) return;
      await Timer(0.5.seconds, primaryWordCardController.flipCard);
      await Timer(0.5.seconds, () async {
        if (isAutoPlayMode.isfalse) return;
        await primaryWordCardController.playWord(completionCallBack: () async {
          // after playWord
          // When we reach the last card or autoPlay turn off
          if (isAutoPlayMode.isfalse || primaryWordIndex.value == 0) {
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
    searchResult.clear();
    searchResult.addAll(wordsList.searchFuzzy(searchQuery.value));
  }

  Future<void> _animateToFirstWord() async {
    if (pageController.hasClients) {
      await pageController.animateToPage(pageController.initialPage,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
  }

  /// Animate to word in track
  Future<void> afterFirstLayout() async {
    // Usually trackLocal will be set along when field declared, but we need it
    // here to ensure it's value not to be overwrite by initPage of  pageController
    primaryWordIndex.trackLocal(primaryWordIndexKey);
    if (pageController.hasClients) {
      await pageController.animateToPage(primaryWordIndex.value,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
  }

  int indexOfWord(Word word) => wordsList.indexOf(word);

  @override
  void onClose() {
    // If we have are at last card, clear track
    if (primaryWordIndex.value == wordsList.length - 1) {
      primaryWordIndex.value = 0;
    }
    lectureService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }
}

enum WordsReviewMode { list, flash_card }

enum SpeakerGender { male, female }
