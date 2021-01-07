import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flip_card/flip_card.dart';
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

  /// Card key
  final cardKey = GlobalKey<FlipCardState>();

  final logger = LoggerService.logger;
  final AudioPlayer audioPlayer = AudioPlayer();

  void toggleFavoriteCard() => lectureService.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  /// Flip our card
  void flipCard() {
    cardKey.currentState.toggleCard();
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    lectureService.showSingleWordCard(word);
  }

  /// Play audio of the word
  Future<void> playWord({Function completionCallBack}) async {
    var wordAudio = word.wordAudioMale;
    if (wordAudio == null) {
      final tts = await _generateTts();
      tts.setCompletionHandler(completionCallBack);
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
      if (completionCallBack!= null) {
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
      {@required String string,
      @required StorageFile audio,
      Function completionCallBack}) async {
    if (audio == null) {
      final tts = await _generateTts();
      await tts.speak(string);
    } else {
      await audioPlayer.play(audio.url);
      if (completionCallBack != null) {
        await completionCallBack();
      }
    }
  }

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
    super.onClose();
  }
}
