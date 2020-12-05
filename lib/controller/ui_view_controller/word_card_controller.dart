import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
  final logger = Get.find<LoggerService>().logger;
  final tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Future<void> onInit() async {
    await tts.setLanguage(LAN_CODE_CN);
    await tts.setSpeechRate(0.5);
    super.onInit();
  }

  void toggleFavoriteCard() => classService.toggleWordLiked(word);

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  /// Play audio of the word
  Future<void> playWord() async {
    var wordAudio = word.wordAudio;
    if (wordAudio.isNull) {
      await tts.speak(word.word.join());
    } else {
      await audioPlayer.play(wordAudio.url);
    }
  }

  /// Play audio of the meanings one by one
  Future<void> playMeaning() async {
    await tts.setLanguage(LAN_CODE_JP);
    await tts.setSpeechRate(0.8);
    await word.wordMeanings.forEach((meaning) async {
      await Timer(
          500.milliseconds, () async => await tts.speak(meaning.meaning));
    });
    await tts.setLanguage(LAN_CODE_CN);
    await tts.setSpeechRate(0.5);
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
    audioPlayer.dispose();
    super.onClose();
  }
}
