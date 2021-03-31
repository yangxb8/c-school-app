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

import '../expand_box.dart';

class SpeechRecordingController extends GetxController {
  SpeechRecordingController(this.exam);

  final logger = LoggerService.logger;
  final audioService = Get.find<AudioService>();

  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  Rx<RecordingStatus> recordingStatus = RecordingStatus.idle.obs;

  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;

  /// Exam this SpeechExamBottomSheet should control.
  final SpeechExam exam;

  /// TencentApi
  final tencentApi = Get.find<ApiService>().tencentApi;

  /// Controller to expand or collapse summary
  final summaryExpandController = ExpandBoxController();

  /// Controller to expand or collapse detail
  final detailExpandController = ExpandBoxController();

  /// Index of hanzi been shown in detail radial chart
  final detailHanziIndex = 0.obs;

  /// latest evaluation result as SetenceInfo
  final Rx<SentenceInfo?> lastResult = null.obs;

  /// When hanzi in result is tapped
  void onHanziTap(int index) => detailHanziIndex.value=index;

  /// Play userSpeech. If wordIndex is specified, play the single word
  void playUserSpeech({int? wordIndex}) async {
    //TODO: implement this!
    throw UnimplementedError();
  }

  /// Play ref speech of exam. If wordIndex is specified, play the single word
  void playRefSpeech({int? wordIndex}) async {
    await audioService.startPlayer(uri:exam.refSpeech!.audio!.url);
  }

  void handleRecordButtonPressed() {
    switch (recordingStatus.value) {
      case RecordingStatus.idle:
        _startRecord();
        break;
      case RecordingStatus.recording:
        _stopRecordAndEvaluate();
        break;
      // If under evaluating do nothing
      case RecordingStatus.evaluating:
        break;
      default:
        break;
    }
  }

  void _startRecord() async {
    if (recordingStatus.value != RecordingStatus.idle) return;
    await audioService.startRecorder();
    detailHanziIndex.value = 0;
    lastResult.value = null;
    recordingStatus.value = RecordingStatus.recording;
  }

  void _stopRecordAndEvaluate() async {
    if (recordingStatus.value != RecordingStatus.recording) return null;
    recordingStatus.value = RecordingStatus.evaluating;
    final file = await audioService.stopRecorder();
    final base64 = base64Encode(file.readAsBytesSync());
    final request = SoeRequest(
        ScoreCoeff: UserService.user.userScoreCoeff,
        RefText: exam.refText,
        UserVoiceData: base64,
        SessionId: Uuid().v1());
    recordingStatus.value = RecordingStatus.idle;
    lastResult.value = await tencentApi.soe(request, file);
  }

}

enum RecordingStatus { recording, evaluating, idle }
