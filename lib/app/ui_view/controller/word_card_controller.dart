// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/model/word_example.dart';
import 'package:c_school_app/app/review_panel/controller/review_words_controller.dart';
import 'package:c_school_app/service/audio_service.dart';
import 'package:c_school_app/service/lecture_service.dart';
import 'package:c_school_app/service/logger_service.dart';

const LAN_CODE_CN = 'zh-cn';

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

  final audioService = Get.find<AudioService>();

  void toggleFavoriteCard() => lectureService.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value!;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  @override
  void onInit() {
    /// Prepare audio file of this card
    <StorageFile>[
      word.wordAudioFemale!,
      word.wordAudioMale!,
      ...word.wordMeanings!.expand((m) => m.exampleFemaleAudios! + m.exampleMaleAudios!)
    ].forEach((file) => audioService.prepareAudio(file.url));
    super.onInit();
  }

  /// Flip our card
  void flipCard() {
    isCardFlipped.toggle();
  }

  /// Show a single word card from dialog
  void showSingleCard(Word word) {
    lectureService.showSingleWordCard(word);
  }

  /// Play audio of the word
  Future<void> playWord({String? audioKey, Function? completionCallBack}) async {
    var wordAudio =
        reviewWordSpeakerGender == SpeakerGender.male ? word.wordAudioMale! : word.wordAudioFemale!;
    await audioService.startPlayer(wordAudio.url, key:audioKey, callback: completionCallBack);
  }

  /// Play audio of the meanings one by one, now only tts is supported
  Future<void> playMeanings({int meaningOrdinal = 0, Function? completionCallBack}) async {
    await audioService.speakList(word.wordMeanings!.map((m) => m.meaning!),
        callback: completionCallBack);
  }

  /// Play audio of the examples
  Future<void> playExample({required WordExample wordExample, required String audioKey, Function? completionCallBack}) async {
    var audio = reviewWordSpeakerGender == SpeakerGender.male
        ? wordExample.audioMale
        : wordExample.audioFemale;
    await audioService.startPlayer(audio.url, key: audioKey, callback: completionCallBack);
  }

  /// Default to Male
  SpeakerGender get reviewWordSpeakerGender => Get.isRegistered<ReviewWordsController>()
      ? Get.find<ReviewWordsController>().speakerGender.value!
      : SpeakerGender.male;

  @override
  void onClose() {
    lectureService.commitChange();
    super.onClose();
  }
}
