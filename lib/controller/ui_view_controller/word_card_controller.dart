import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/app/model/word_example.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';
const LAN_CODE_JP = 'ja';

class WordCardController extends GetxController {
  WordCardController(this.word);

  final Word word;
  final LectureService lectureService = Get.find();

  /// Words user favorite
  final RxList<String> _userLikedWordIds = LectureService.userLikedWordIds_Rx;

  /// Is hint shown under meaning
  final isHintShown = false.obs;

  /// Is the card flipped to back
  final isCardFlipped = false.obs;

  final logger = LoggerService.logger;
  final AudioPlayer audioPlayer = AudioPlayer();

  void toggleFavoriteCard() => lectureService.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  /// Flip our card
  void flipCard() {
    isCardFlipped.toggle();
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    lectureService.showSingleWordCard(word);
  }

  /// Play audio of the word
  Future<void> playWord({Function completionCallBack}) async {
    var wordAudio = reviewWordSpeakerGender == SpeakerGender.male
        ? word.wordAudioMale
        : word.wordAudioFemale;
    if (wordAudio == null) {
      final tts = await _generateTts();
      tts.setCompletionHandler(completionCallBack);
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
      await audioPlayer.onPlayerCompletion.first;
      if (completionCallBack != null) {
        await completionCallBack();
      }
    }
  }

  /// Play audio of the meanings one by one, now only tts is supported
  Future<void> playMeanings(
      {int meaningOrdinal = 0, Function completionCallBack}) async {
    final tts = await _generateTts(language: LAN_CODE_JP);
    if (meaningOrdinal == word.wordMeanings.length - 1) {
      tts.setCompletionHandler(completionCallBack);
    }
    // If it's not the last meaning, set handler to play the next meaning
    else {
      tts.setCompletionHandler(() => playMeanings(
          meaningOrdinal: meaningOrdinal + 1,
          completionCallBack: completionCallBack));
    }
    await Timer(0.5.seconds,
        () async => await tts.speak(word.wordMeanings[meaningOrdinal].meaning));
  }

  /// Play audio of the examples
  Future<void> playExample(
      {@required WordExample wordExample, Function completionCallBack}) async {
    var audio = reviewWordSpeakerGender == SpeakerGender.male
        ? wordExample.audioMale
        : wordExample.audioFemale;
    if (audio == null) {
      final tts = await _generateTts();
      await tts.speak(wordExample.example);
    } else {
      await audioPlayer.play(audio.url);
      await audioPlayer.onPlayerCompletion.first;
      if (completionCallBack != null) {
        await completionCallBack();
      }
    }
  }

  /// Default to Male
  SpeakerGender get reviewWordSpeakerGender =>
      Get.isRegistered<ReviewWordsController>()
          ? Get.find<ReviewWordsController>().speakerGender.value
          : SpeakerGender.male;

  Future<FlutterTts> _generateTts({String language = LAN_CODE_CN}) async {
    final tts = FlutterTts();
    await tts.setLanguage(language);
    switch (language) {
      case LAN_CODE_JP:
        await tts.setSpeechRate(0.8);
        break;
      case LAN_CODE_CN:
        await tts.setSpeechRate(0.5);
        break;
      default:
        await tts.setSpeechRate(0.8);
    }
    return tts;
  }

  @override
  void onClose() {
    lectureService.commitChange();
    audioPlayer.dispose();
    logger.i('Word card Controller destroyed');
    super.onClose();
  }
}
