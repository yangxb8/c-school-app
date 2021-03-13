// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/soe_request.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/service/api_service.dart';
import 'package:c_school_app/service/audio_service.dart';
import 'package:c_school_app/service/logger_service.dart';
import 'package:c_school_app/service/user_service.dart';

class SpeechRecordingController extends GetxController {
  final logger = LoggerService.logger;
  final audioService = Get.find<AudioService>();

  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  Rx<RecordingStatus> recordingStatus = RecordingStatus.IDLE.obs;

  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;

  /// Exam this SpeechExamBottomSheet should control.
  final SpeechExam exam;

  /// TencentApi
  final tencentApi = Get.find<ApiService>().tencentApi;

  SpeechRecordingController(this.exam);

  /// Most recent speech recorded by this controller
  void playUserSpeech() async {
    throw UnimplementedError();
  }

  void handleRecordButtonPressed() {
    switch (recordingStatus.value) {
      case RecordingStatus.IDLE:
        _startRecord();
        break;
      case RecordingStatus.RECORDING:
        _stopRecordAndEvaluate();
        break;
      // If under evaluating do nothing
      case RecordingStatus.EVALUATING:
        break;
      default:
        break;
    }
  }

  void _startRecord() async {
    if (recordingStatus.value != RecordingStatus.IDLE) return;
    await audioService.startRecorder();
    recordingStatus.value = RecordingStatus.RECORDING;
  }

  Future<SentenceInfo?> _stopRecordAndEvaluate() async {
    if (recordingStatus.value != RecordingStatus.RECORDING) return null;
    recordingStatus.value = RecordingStatus.EVALUATING;
    final file = await audioService.stopRecorder();
    final base64 = base64Encode(file.readAsBytesSync());
    final request = SoeRequest(
        ScoreCoeff: UserService.user.userScoreCoeff,
        RefText: exam.refText,
        UserVoiceData: base64,
        SessionId: Uuid().v1());
    // Call native method and save result to latest userSpeech instance
    var result = await tencentApi.soe(request, file);
    recordingStatus.value = RecordingStatus.IDLE;
    return result;
  }
}

enum RecordingStatus { RECORDING, EVALUATING, IDLE }
