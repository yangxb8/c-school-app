// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import '../../data/model/exam/speech_exam.dart';

import '../../core/utils/speech_exam_adaptor.dart';
import '../speech_evaluation/speech_evaluation.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/word/word.dart';
import '../../data/model/word/word_example.dart';
import '../../core/service/audio_service.dart';
// 🌎 Project imports:
import '../../core/service/lecture_service.dart';
import '../../core/service/logger_service.dart';
import '../../modules/review_panel/review_words/review_words_detail_controller.dart';

const LAN_CODE_CN = 'zh-cn';

class WordCardController extends GetxController {
  WordCardController(this.word);

  static final LectureService lectureHelper = Get.find<LectureService>();

  final audioService = Get.find<AudioService>();

  /// Is the card flipped to back
  final isCardFlipped = false.obs;

  /// Is hint shown under meaning
  final isHintShown = false.obs;

  final logger = LoggerService.logger;
  final Word word;

  /// Words user favorite
  late final RxList<String> _userLikedWordIds =
      lectureHelper.userLikedWordIds_Rx;

  @override
  void onClose() {
    lectureHelper.commitChange();
    super.onClose();
  }

  @override
  void onInit() {
    /// Prepare audio file of this card
    <StorageFile>[
      word.wordAudioFemale!.audio!,
      word.wordAudioMale!.audio!,
      ...word.wordMeanings!
          .expand((m) => m.examples!.map((e) => e.audioMale!.audio!)),
      ...word.wordMeanings!
          .expand((m) => m.examples!.map((e) => e.audioFemale!.audio!)),
    ].forEach((file) => audioService.prepareAudio(file.url));
    super.onInit();
  }

  void toggleFavoriteCard() => lectureHelper.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  /// Flip our card
  void flipCard() {
    isCardFlipped.toggle();
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    lectureHelper.showSingleWordCard(word);
  }

  /// Play audio of the word
  Future<void> playWord(
      {required String audioKey, Function? completionCallBack}) async {
    var wordAudio = reviewWordSpeakerGender == SpeakerGender.male
        ? word.wordAudioMale!
        : word.wordAudioFemale!;
    await audioService.startPlayer(
        uri: wordAudio.audio!.url, key: audioKey, callback: completionCallBack);
  }

  /// Play audio of the meanings one by one, now only tts is supported
  Future<void> playMeanings({int meaningOrdinal = 0}) async {
    await audioService.speakList(word.wordMeanings!.map((m) => m.meaning!));
  }

  /// Play audio of the examples
  Future<void> playExample(
      {required WordExample wordExample,
      required String audioKey,
      Function? completionCallBack}) async {
    var speechAudio = reviewWordSpeakerGender == SpeakerGender.male
        ? wordExample.audioMale
        : wordExample.audioFemale;
    await audioService.startPlayer(
        uri: speechAudio!.audio!.url,
        key: audioKey,
        callback: completionCallBack);
  }

  /// Default to Male
  SpeakerGender get reviewWordSpeakerGender =>
      Get.isRegistered<ReviewWordsController>()
          ? Get.find<ReviewWordsController>().speakerGender.value
          : SpeakerGender.male;

  void showSpeechEvaluationForWord() =>
      _showSpeechEvaluationBottomSheet(SpeechExamAdaptor.wordToExam(word));

  void showSpeechEvaluationForExample(WordExample wordExample) =>
      _showSpeechEvaluationBottomSheet(
          SpeechExamAdaptor.WordExampleToExam(wordExample));

  void _showSpeechEvaluationBottomSheet(SpeechExam exam) => Get.bottomSheet(
        SpeechEvaluation(
          exam: exam,
        ),
        elevation: 2.0,
        backgroundColor: Colors.white,
      );
}
