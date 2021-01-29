import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/service/app_state_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_animations/simple_animations.dart';
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
import '../../../i18n/review_words.i18n.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController
    with SingleGetTickerProviderMixin {
  final LectureService lectureService = Get.find();
  final logger = LoggerService.logger;

  /// If all words mode, there will be no associated lecture
  Lecture associatedLecture;

  /// WordsList for this lecture(s)
  List<Word> wordsList = [];

  /// List or card
  final _mode = WordsReviewMode.list.obs;

  /// True if we are in autoPlay mode
  RxBool isAutoPlayMode = false.obs;

  /// Controller for search bar of review words screen
  final searchBarController = FloatingSearchBarController();

  /// Animate icon shape, it will auto-play by worker when color change
  AnimationController searchBarPlayIconController;

  /// Animate icon color
  Rx<CustomAnimationControl> searchBarPlayIconControl =
      CustomAnimationControl.STOP.obs;

  /// Search query of search bar
  RxString searchQuery = ''.obs;

  /// Result of search bar
  RxList<Word> searchResult = <Word>[].obs;

  /// Speaker gender of all audio (tts not supported)
  Rx<SpeakerGender> speakerGender = SpeakerGender.male.obs;

  /// [WordsList] audio player
  final AudioPlayer audioPlayer = AudioPlayer();

  /// [WordsList] fallback when no audio was found for word
  FlutterTts tts;

  /// [WordsList] Controller for words list
  final groupedItemScrollController = GroupedItemScrollController();

  /// [WordsList] If word list is first time rendered
  bool isListFirstRender = true;

  /// [WordsFlashcard] pageController
  PageController pageController;

  /// [WordsFlashcard] Key for primaryWordIndex to save by localStorage
  static const primaryWordIndexKey = 'ReviewWordsController.primaryWordIndex';

  /// [WordsFlashcard] Current primary word index in _wordList
  final primaryWordIndex = 0.obs;

  /// [WordsFlashcard] Controller of primary card
  WordCardController primaryWordCardController;

  /// [WordsFlashcard] WordsHistory of this user
  RxList<WordHistory> _userWordsHistory;

  /// [WordsFlashcard] Reversed Words List for flashCard
  List<Word> reversedWordsList = [];

  /// [WordsFlashcard] WordMemoryStatus of primary word
  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  /// [WordsFlashcard] Used to controller pagination of card
  RxDouble pageFraction;

  @override
  Future<void> onInit() async {
    _userWordsHistory = LectureService.userWordsHistory_Rx;
    associatedLecture =
        lectureService.findLectureById(Get.parameters['lectureId']);
    if (Get.arguments == null) {
      wordsList = associatedLecture != null
          ? associatedLecture.words
          : LectureService.allWords;
      // If wordsList is provided, use it
    } else if (Get.arguments is List<Word>) {
      wordsList = Get.arguments;
    }
    // As our flashcards are stack from bottom to top, reverse the words order
    reversedWordsList = wordsList.reversed.toList();
    pageFraction = (wordsList.length - 1.0).obs;
    pageController = PageController(initialPage: wordsList.length - 1);
    searchBarPlayIconController =
        AnimationController(vsync: this, duration: 0.3.seconds);
    // worker to monitor search query change and fire search function
    debounce(searchQuery, (_) => search(), time: Duration(seconds: 1));
    // Worker to flip back primary card when it change
    ever(primaryWordIndex, (_) => flipBackPrimaryCard());
    // Worker to sync color and icon change of playIcon
    ever(searchBarPlayIconControl, (value) {
      if (value == CustomAnimationControl.PLAY_FROM_START) {
        searchBarPlayIconController.forward();
      } else if (value == CustomAnimationControl.PLAY_REVERSE_FROM_END) {
        searchBarPlayIconController.reverse();
      }
    });
    // If is a specific lecture, add it to history
    if (associatedLecture != null) {
      lectureService.addLectureReviewedHistory(associatedLecture);
    }
    if (AppStateService.isDebug) {
      AudioPlayer.logEnabled = true;
    }
    super.onInit();
  }

  /// Flashcard or List mode
  WordsReviewMode get mode => _mode.value;

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    lectureService.showSingleWordCard(word);
  }

  /// [WordsFlashcard] PrimaryWord associated with primaryWordIndex
  Word get primaryWord => reversedWordsList[primaryWordIndex.value];

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
    Fluttertoast.showToast(
        msg: 'Change to %s speaker'
            .i18n
            .fill([EnumToString.convertToString(speakerGender.value).i18n]));
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
      searchBarPlayIconControl.value = CustomAnimationControl.PLAY_FROM_START;
      isAutoPlayMode.value = true;
      // Play from beginning
      await _animateToFirstWord();
      flipBackPrimaryCard();
      _autoPlayCard();
    } else {
      searchBarPlayIconControl.value =
          CustomAnimationControl.PLAY_REVERSE_FROM_END;
      isAutoPlayMode.value = false;
    }
  }

  /// [WordsList] Simplified version of same method in WordCard
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
      if (tts == null) {
        tts = FlutterTts();
        await tts.setLanguage(LAN_CODE_CN);
        await tts.setSpeechRate(0.5);
      }
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  /// [WordsFlashcard]
  int countWordMemoryStatusOfWordByStatus(
          {@required WordMemoryStatus status}) =>
      _userWordsHistory
          .filter((history) =>
              history.wordId == primaryWord.wordId &&
              history.wordMemoryStatus == status)
          .length;

  /// [WordsFlashcard]
  void handWordMemoryStatusPressed(WordMemoryStatus status) {
    if (wordMemoryStatus.value == status) {
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    } else {
      wordMemoryStatus.value = status;
    }
  }

  /// [WordsFlashcard] Save status to history
  void saveAndResetWordHistory(Word word) {
    if (wordMemoryStatus.value != WordMemoryStatus.NOT_REVIEWED) {
      lectureService.addWordReviewedHistory(word,
          status: wordMemoryStatus.value);
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    }
  }

  /// [WordsFlashcard] Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if (primaryWordCardController != null &&
        primaryWordCardController.isCardFlipped.isTrue) {
      primaryWordCardController.flipCard();
    }
  }

  /// [WordsFlashcard] animate to next card
  Future<void> nextCard() async => await pageController.previousPage(
      duration: 300.milliseconds, curve: Curves.easeInOut);

  /// [WordsFlashcard] animate to last card
  Future<void> previousCard() async => await pageController.nextPage(
      duration: 300.milliseconds, curve: Curves.easeInOut);

  /// [WordsFlashcard] Tts package use listener to handler completion of speech
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
            searchBarPlayIconControl.value =
                CustomAnimationControl.PLAY_REVERSE_FROM_END;
            isAutoPlayMode.value = false;
          } else {
            await nextCard();
            Future.delayed(1.seconds, _autoPlayCard);
          }
        });
      });
    });
  }

  /// [WordsFlashcard]
  Future<void> _animateToFirstWord() async {
    if (pageController.hasClients) {
      await pageController.animateToPage(pageController.initialPage,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
  }

  /// [WordsFlashcard] Animate to word in track
  Future<void> afterFirstLayout() async {
    // Usually trackLocal will be set along when field declared, but we need it
    // here to ensure it's value not to be overwrite by initPage of  pageController
    primaryWordIndex.trackLocal(primaryWordIndexKey);
    if (pageController.hasClients) {
      await pageController.animateToPage(primaryWordIndex.value,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
  }

  @override
  void onClose() {
    // If we have are at last card, clear track
    if (primaryWordIndex.value == 0) {
      primaryWordIndex.value = wordsList.length - 1;
    }
    lectureService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }
}

enum WordsReviewMode { list, flash_card }

enum SpeakerGender { male, female }
