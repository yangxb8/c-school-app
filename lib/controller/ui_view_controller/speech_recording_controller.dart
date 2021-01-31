// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/exceptions/sound_exceptions.dart';
import 'package:c_school_app/service/app_state_service.dart';
import '../../app/model/speech_exam.dart';
import '../../service/api_service.dart';

class SpeechRecordingController extends GetxController {
  static const platform = MethodChannel('soe');
  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  RecordingStatus recordingStatus = RecordingStatus.IDLE;
  /// Current evaluation result
  SentenceInfo sentenceInfo;
  /// Current speechData file path
  String speechDataPath;
  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;
  /// Exam this SpeechExamBottomSheet should control.
  SpeechExam exam;
  /// Used to play question and user speech
  AudioPlayer _myPlayer;
  /// TencentApi
  final tencentApi = Get.find<ApiService>().tencentApi;

  SpeechRecordingController.forExam(this.exam);

  @override
  Future<void> onInit() async {
    _myPlayer = await AudioPlayer();
    AudioPlayer.logEnabled = AppStateService.isDebug;
    super.onInit();
  }

  void startRecord() async {
    assert(exam!= null);
    // Verify permission
    if (recordingStatus != RecordingStatus.IDLE) return;
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw RecordingPermissionException();
    }
    recordingStatus = RecordingStatus.RECORDING;
    // Call native method
    await tencentApi.soeStartRecord(exam);
  }

  void stopRecordAndEvaluate() async {
    recordingStatus = RecordingStatus.EVALUATING;
    // Call native method and save result to latest userSpeech instance
    var result = await tencentApi.soeStopRecordAndEvaluate();
    speechDataPath = result['audioPath'];
    sentenceInfo = result['evaluationResult'];
  }

  /// Most recent speech recorded by this controller
  void playUserSpeech() async {
    _playFromPath(speechDataPath);
  }

  void _playFromPath(String path,{bool isLocal}) async {
    // If recording, do nothing
    if ((recordingStatus != RecordingStatus.IDLE)) return;
    // If already playing, stop it and play selected buffer.
    await _myPlayer.stop();
    await _myPlayer.play(speechDataPath, isLocal: isLocal);
  }

  /// Ensure resource are released
  @override
  void onClose() {
    if (_myPlayer != null) {
      _myPlayer.dispose();
    }
    super.onClose();
  }

  void handleRecordButtonPressed() {
    switch(recordingStatus){
      case RecordingStatus.IDLE:
        startRecord();
        break;
      case RecordingStatus.RECORDING:
        stopRecordAndEvaluate();
        break;
        // If under evaluating do nothing
      case RecordingStatus.EVALUATING:
        break;
    }
  }
}

enum RecordingStatus { RECORDING, EVALUATING, IDLE }
