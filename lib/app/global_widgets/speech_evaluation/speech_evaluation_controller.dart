// 🎯 Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// 🌎 Project imports:
import 'package:c_school_app/app/data/model/api_request/soe_request.dart';
import 'package:c_school_app/app/data/repository/user_repository.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:supercharged/supercharged.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/helper/api_helper.dart';
import '../../data/model/exam/speech_evaluation_result.dart';
import '../../data/model/exam/speech_exam.dart';
import '../../core/service/audio_service.dart';
import '../../core/service/logger_service.dart';
import '../expand_box.dart';
import '../../core/utils/index.dart';

class SpeechEvaluationController extends GetxController {
  SpeechEvaluationController(this.exam);

  final audioService = Get.find<AudioService>();

  /// Controller to expand or collapse detail
  final detailExpandController = ExpandBoxController();

  /// Index of hanzi been shown in detail radial chart
  final detailHanziIndex = 0.obs;

  /// Exam this SpeechExamBottomSheet should control.
  final SpeechExam exam;

  /// latest evaluation result as SentenceInfo
  final Rx<SentenceInfo?> lastResult = null.obs;

  /// Last speech recorded by user
  Uint8List? lastSpeech;

  final logger = LoggerService.logger;

  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  Rx<RecordingStatus> recordingStatus = RecordingStatus.idle.obs;

  /// Controller to expand or collapse summary
  final summaryExpandController = ExpandBoxController();

  /// TencentApi
  final tencentApiHelper = TencentApiHelper();

  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;

  /// When ref hanzi is tapped. The index should be count without punctuation.
  void onRefHanziTap(int index) {
    playRefSpeech(wordIndex: exam.refText!.indexWithoutPunctuation(index));
  }

  /// When hanzi in result is tapped. The index should be count without punctuation.
  void onResultHanziTap(int index) {
    if (lastResult.value == null || lastSpeech == null) return;
    playUserSpeech(wordIndex: exam.refText!.indexWithoutPunctuation(index));
  }

  /// Play userSpeech. If wordIndex is specified, play the single word
  void playUserSpeech({int? wordIndex}) async {
    var from;
    var to;
    if (wordIndex != null) {
      from = lastResult.value?.words?[wordIndex].beginTime?.milliseconds;
      to = lastResult.value?.words?[wordIndex].endTime?.milliseconds;
      if (from == null || to == null) {
        logger.w('No start or end time found for word index $wordIndex');
        return;
      }
    }
    await audioService.startPlayer(
        bytes: lastSpeech, key: '${exam.refText!}:user', from: from, to: to);
  }

  /// Play ref speech of exam. If wordIndex is specified, play the single word
  void playRefSpeech({int? wordIndex}) async {
    var from;
    var to;
    if (wordIndex != null) {
      from = exam.refSpeech!.timeSeries![wordIndex];
      to = exam.refSpeech!.timeSeries!.elementAtOrNull(wordIndex + 1);
    }
    await audioService.startPlayer(
        uri: exam.refSpeech!.audio!.url,
        key: '${exam.refText!}:ref',
        from: from,
        to: to);
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
    lastSpeech = file.readAsBytesSync();
    final base64 = base64Encode(lastSpeech!);
    final request = SoeRequest(
        ScoreCoeff: Get.find<UserRepository>().currentUser.userScoreCoeff,
        RefText: exam.refTextAsString,
        UserVoiceData: base64,
        SessionId: Uuid().v1());
    recordingStatus.value = RecordingStatus.idle;
    lastResult.value = await tencentApiHelper.soe(request, file);
  }
}

enum RecordingStatus { recording, evaluating, idle }
