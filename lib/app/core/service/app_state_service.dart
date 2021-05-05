// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'localstorage_service.dart';
import '../utils/index.dart';

const audioSpeedKey = 'audioSpeed';
const audioSpeedPossible = [1.0, 0.5];

/*
* This class provide global AppState from shared_preference/others
* This service use LocalStorageService so they must be
* initialized first!
*/
class AppStateService extends GetxService {
  final LocalStorageService _localStorageService = Get.find();

  /// After user login and lecture is loaded, this will be set to true
  final RxBool _fullyInitialized = false.obs;

  /// How many time this app has started
  late final int startCount;

  /// Speaker gender of all audio (tts not supported)
  final Rx<SpeakerGender> _speakerGender = SpeakerGender.male.obs;

  /// Speed when audio is played
  final RxDouble _audioSpeed = 1.0.obs.trackLocal(audioSpeedKey);

  @override
  void onInit() {
    super.onInit();
    startCount = _localStorageService.getStartCountAndIncrease();
  }

  RxBool get fullyInitialized => _fullyInitialized;

  Rx<SpeakerGender> get speakerGender => _speakerGender;

  RxDouble get audioSpeed => _audioSpeed;

  bool get isDebug {
    var debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  void fullyInitializedComplete() {
    assert(_fullyInitialized.isFalse);
    _fullyInitialized.value = true;
  }

  /// Male or Female
  void toggleSpeakerGender() {
    speakerGender.value = speakerGender.value == SpeakerGender.male
        ? SpeakerGender.female
        : SpeakerGender.male;
    Fluttertoast.showToast(
        msg: 'review.word.toast.changeSpeaker'.trParams({
      'gender': speakerGender.value == SpeakerGender.male
          ? 'review.word.toast.changeSpeaker.male'.tr
          : 'review.word.toast.changeSpeaker.female'.tr
    })!);
  }

  /// 1X -> 0.5X
  void toggleAudioSpeed() {
    final currentSpeedIndex = audioSpeedPossible.indexOf(_audioSpeed.value);
    if (currentSpeedIndex == audioSpeedPossible.length - 1) {
      _audioSpeed.value = audioSpeedPossible[0];
    } else {
      _audioSpeed.value = audioSpeedPossible[currentSpeedIndex + 1];
    }
  }
}

enum SpeakerGender { male, female }
