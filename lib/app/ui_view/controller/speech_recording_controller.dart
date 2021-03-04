// 🐦 Flutter imports:
import 'package:c_school_app/service/audio_service.dart';
import 'package:c_school_app/service/logger_service.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/service/api_service.dart';

class SpeechRecordingController extends GetxController {
  final audioService = Get.find<AudioService>();
  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  Rx<RecordingStatus> recordingStatus = RecordingStatus.IDLE.obs;
  /// Current speechData file path
  String speechDataPath;
  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;
  /// Exam this SpeechExamBottomSheet should control.
  final SpeechExam exam;
  /// TencentApi
  final tencentApi = Get.find<ApiService>().tencentApi;

  SpeechRecordingController(this.exam);

  /// Most recent speech recorded by this controller
  void playUserSpeech() async {
    // If recording, do nothing
    if ((recordingStatus.value != RecordingStatus.IDLE)) return;
    // If already playing, stop it and play selected buffer.
    await audioService.play(speechDataPath);
  }

  void handleRecordButtonPressed() {
    switch(recordingStatus.value){
      case RecordingStatus.IDLE:
        _startRecord();
        break;
      case RecordingStatus.RECORDING:
        _stopRecordAndEvaluate();
        break;
        // If under evaluating do nothing
      case RecordingStatus.EVALUATING:
        break;
    }
  }

  void _startRecord() async {
    assert(exam!= null);
    // Verify permission
    if (recordingStatus.value != RecordingStatus.IDLE) return;
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      await Fluttertoast.showToast(msg: 'Please allow the microphone usage');
    }
    // Call native method
    await tencentApi.soeStartRecord(exam);
    recordingStatus.value = RecordingStatus.RECORDING;
  }

  void _stopRecordAndEvaluate() async {
    recordingStatus.value = RecordingStatus.EVALUATING;
    // Call native method and save result to latest userSpeech instance
    var result = await tencentApi.soeStopRecordAndEvaluate();
    LoggerService.logger.i(result['audioPath']);
    LoggerService.logger.i(result['evaluationResult']);
    recordingStatus.value = RecordingStatus.IDLE;
  }
}

enum RecordingStatus { RECORDING, EVALUATING, IDLE }
