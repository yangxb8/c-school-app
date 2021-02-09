// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/ui_view/controller/word_card_controller.dart';
import 'package:c_school_app/service/app_state_service.dart';
import 'package:c_school_app/service/audio_service.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/service/logger_service.dart';
import '../../../i18n/review_words.i18n.dart';
import '../../../util/extensions.dart';

const LAN_CODE_CN = 'zh-cn';

class ReviewWordsController extends GetxController with SingleGetTickerProviderMixin {
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

  /// Animate icon shape, it will auto-play by worker when color change
  AnimationController searchBarPlayIconController;

  /// Animate icon color
  Rx<CustomAnimationControl> searchBarPlayIconControl = CustomAnimationControl.STOP.obs;

  /// Speaker gender of all audio (tts not supported)
  Rx<SpeakerGender> speakerGender = SpeakerGender.male.obs;

  /// If this is set, afterFirstLayout will animate to the word instead of tracked one
  int _jumpToWord;

  /// Audio Service
  final AudioService audioService = Get.find();

  /// [WordsFlashcard] pageController
  PageController pageController;

  /// [WordsFlashcard] Key for primaryWordIndex to save by localStorage
  static const primaryWordIndexKey = 'ReviewWordsController.primaryWordIndex';

  /// [WordsFlashcard] Current primary word index in _wordList
  final primaryWordIndex = 0.obs;

  /// [WordsFlashcard] Controller of primary card
  WordCardController primaryWordCardController;

  /// [WordsFlashcard] Reversed Words List for flashCard
  List<Word> reversedWordsList = [];

  /// [WordsFlashcard] WordMemoryStatus of primary word
  Rx<WordMemoryStatus> wordMemoryStatus = WordMemoryStatus.NOT_REVIEWED.obs;

  /// [WordsFlashcard] Used to controller pagination of card
  RxDouble pageFraction;

  /// [WordsFlashCard] If word card is first time rendered
  bool isCardFirstRender = true;

  /// [WordsFlashCard] Should be go back to first card if last card is reach
  /// If false then a toast will be show to inform user that we will go back to first card
  bool backToFirstCard = false;

  @override
  Future<void> onInit() async {
    associatedLecture = lectureService.findLectureById(Get.parameters['lectureId']);
    if (Get.arguments == null) {
      wordsList = associatedLecture != null ? associatedLecture.words : LectureService.allWords;
      // If wordsList is provided, use it
    } else if (Get.arguments is List<Word>) {
      wordsList = Get.arguments;
    }
    // As our flashcards are stack from bottom to top, reverse the words order
    reversedWordsList = wordsList.reversed.toList();
    pageFraction = (wordsList.length - 1.0).obs;
    pageController = PageController(initialPage: wordsList.length - 1);
    searchBarPlayIconController = AnimationController(vsync: this, duration: 0.3.seconds);
    // Worker when primary card change
    ever(primaryWordIndex, (_) {
      flipBackPrimaryCard();
    });
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

  /// In autoPlay, user is restricted to card mode, this might need to be changed for better UX
  void changeMode() {
    // If in autoPlay mode, stop it
    if (isAutoPlayMode.value) {
      isAutoPlayMode.value = false;
    }
    if (_mode.value == WordsReviewMode.flash_card) {
      saveAndResetWordHistory();
      _mode.value = WordsReviewMode.list;
      logger.i('Change to List Mode');
    } else {
      _mode.value = WordsReviewMode.flash_card;
      logger.i('Change to Card Mode');
    }
  }

  /// Male or Female
  void toggleSpeakerGender() {
    speakerGender.value =
        speakerGender.value == SpeakerGender.male ? SpeakerGender.female : SpeakerGender.male;
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
      flipBackPrimaryCard();
      _autoPlayCard();
    } else {
      searchBarPlayIconControl.value = CustomAnimationControl.PLAY_REVERSE_FROM_END;
      isAutoPlayMode.value = false;
    }
  }

  /// [WordsList] Simplified version of same method in WordCard
  /// As we might need to play from word list.
  ///
  /// Play audio of the word
  Future<void> playWord({@required Word word, @required String audioKey}) async {
    if (isAutoPlayMode.value || word == null) return;
    var wordAudio =
        speakerGender.value == SpeakerGender.male ? word.wordAudioMale : word.wordAudioFemale;
    if (wordAudio == null) {
      return;
    }
    await audioService.play(wordAudio.url, key: audioKey);
  }

  /// [WordsList] Jump to card in flash card mode
  void jumpToCard(int index) {
    // Index from words list is for wordsList, however flashcard use reversedWordsList.
    _jumpToWord = wordsList.length - 1 - index;
    if (_mode.value == WordsReviewMode.list) {
      changeMode();
    }
  }

  /// [WordsFlashcard]
  void handWordMemoryStatusPressed(WordMemoryStatus status) {
    if (wordMemoryStatus.value == status) {
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    } else {
      wordMemoryStatus.value = status;
    }
  }

  /// [WordsFlashcard] Save status to history
  void saveAndResetWordHistory() {
    if (wordMemoryStatus.value != WordMemoryStatus.NOT_REVIEWED) {
      lectureService.addWordReviewedHistory(primaryWord, status: wordMemoryStatus.value);
      wordMemoryStatus.value = WordMemoryStatus.NOT_REVIEWED;
    }
  }

  /// [WordsFlashcard] Make sure primary card is front side when slide
  void flipBackPrimaryCard() {
    if (primaryWordCardController != null && primaryWordCardController.isCardFlipped.isTrue) {
      primaryWordCardController.flipCard();
    }
  }

  /// [WordsFlashcard] animate to next card
  Future<void> nextCard() async {
    saveAndResetWordHistory();
    if (primaryWordIndex.value == 0) {
      if (backToFirstCard) {
        await _animateToFirstWord();
        backToFirstCard = false;
      } else {
        await Fluttertoast.showToast(
            gravity: ToastGravity.CENTER,
            msg: 'Last card reached. Swipe left will go to first card'.i18n);
        backToFirstCard = true;
      }
    } else {
      await pageController.previousPage(duration: 300.milliseconds, curve: Curves.easeInOut);
    }
  }

  /// [WordsFlashcard] animate to last card
  Future<void> previousCard() async {
    saveAndResetWordHistory();
    await pageController.nextPage(duration: 300.milliseconds, curve: Curves.easeInOut);
  }

  /// [WordsFlashcard] Tts package use listener to handler completion of speech
  /// So we need to set logic after each tts speech inside a
  /// callback function
  ///
  /// Also, we check isAutoPlayMode in multiple stage so user
  /// can stop the play anytime
  void _autoPlayCard() async {
    if (isAutoPlayMode.isfalse) {
      searchBarPlayIconControl.value = CustomAnimationControl.PLAY_REVERSE_FROM_END;
      return;
    }
    await primaryWordCardController.playMeanings(completionCallBack: () async {
      // after playMeanings
      if (isAutoPlayMode.isfalse) {
        searchBarPlayIconControl.value = CustomAnimationControl.PLAY_REVERSE_FROM_END;
        return;
      }
      await Timer(0.5.seconds, primaryWordCardController.flipCard);
      await Timer(0.5.seconds, () async {
        if (isAutoPlayMode.isfalse) {
          searchBarPlayIconControl.value = CustomAnimationControl.PLAY_REVERSE_FROM_END;
          return;
        }
        await primaryWordCardController.playWord(completionCallBack: () async {
          // after playWord
          // When we reach the last card or autoPlay turn off
          if (isAutoPlayMode.isfalse || primaryWordIndex.value == 0) {
            searchBarPlayIconControl.value = CustomAnimationControl.PLAY_REVERSE_FROM_END;
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
    if (isCardFirstRender) {
      primaryWordIndex.trackLocal(primaryWordIndexKey);
    }
    // If _jumpToWord is set, animate to it. Otherwise animate to tracked word
    _jumpToWord ??= primaryWordIndex.value;
    if (pageController.hasClients) {
      await pageController.animateToPage(_jumpToWord,
          duration: 0.5.seconds, curve: Curves.easeInOut);
    }
    // Clear jumpToWord
    _jumpToWord = null;
    if (isCardFirstRender) isCardFirstRender = false;
  }

  @override
  void onClose() {
    // If we have are at last card, clear track
    if (primaryWordIndex.value == 0) {
      primaryWordIndex.value = wordsList.length - 1;
    }
    saveAndResetWordHistory();
    lectureService.commitChange();
    super.onClose();
  }
}

enum WordsReviewMode { list, flash_card }

enum SpeakerGender { male, female }
