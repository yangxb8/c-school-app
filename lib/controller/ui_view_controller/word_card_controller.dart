import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/app/ui_view/word_card.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flip/flip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:c_school_app/service/class_service.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';
const LAN_CODE_JP = 'ja';

class WordCardController extends GetxController {
  WordCardController(this.word);
  final Word word;
  final FlipController flipController = FlipController();
  final ClassService classService = Get.find();

  /// Words user favorite
  final RxList<String> _userLikedWordIds = ClassService.userLikedWordIds_Rx;
  /// Is hint shown under meaning
  final isHintShown = false.obs;
  final logger = LoggerService.logger;
  final AudioPlayer audioPlayer = AudioPlayer();

  void toggleFavoriteCard() => classService.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  /// Play audio of the word
  Future<void> playWord({Function completionCallBack}) async {
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      final tts = await _generateTts();
      tts.setCompletionHandler(completionCallBack);
      await tts.speak(word.wordAsString);
    } else {
      await audioPlayer.play(wordAudio.url);
      if (!completionCallBack.isNull) {
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
    if (audio.isNull) {
      final tts = await _generateTts();
      await tts.speak(string);
    } else {
      await audioPlayer.play(audio.url);
      if (!completionCallBack.isNull) {
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

  @override
  void onClose() {
    classService.commitChange();
    audioPlayer.dispose();
    super.onClose();
  }

}
