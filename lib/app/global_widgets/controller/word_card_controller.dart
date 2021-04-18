// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../core/utils/helper/lecture_helper.dart';
import '../../data/model/word/word.dart';
import '../../data/model/word/word_example.dart';
import '../../data/service/audio_service.dart';
import '../../data/service/logger_service.dart';
import '../../modules/review_panel/review_words/review_words_detail_controller.dart';

const LAN_CODE_CN = 'zh-cn';

class WordCardController extends GetxController {
  WordCardController(this.word);

  final Word word;
  final LectureHelper lectureHelper = LectureHelper();

  /// Words user favorite
  late final RxList<String> _userLikedWordIds;

  /// Is hint shown under meaning
  final isHintShown = false.obs;

  /// Is the card flipped to back
  final isCardFlipped = false.obs;

  final logger = LoggerService.logger;

  final audioService = Get.find<AudioService>();

  void toggleFavoriteCard() => lectureHelper.toggleWordLiked(word);

  void toggleHint() => isHintShown.value = !isHintShown.value;

  bool isWordLiked() => _userLikedWordIds.contains(word.wordId);

  @override
  void onInit() {
    _userLikedWordIds = lectureHelper.userLikedWordIds_Rx;
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
  Future<void> playMeanings(
      {int meaningOrdinal = 0, Function? completionCallBack}) async {
    await audioService.speakList(word.wordMeanings!.map((m) => m.meaning!),
        callback: completionCallBack);
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

  @override
  void onClose() {
    lectureHelper.commitChange();
    super.onClose();
  }
}
