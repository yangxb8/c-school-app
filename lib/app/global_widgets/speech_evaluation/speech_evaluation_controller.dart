// 🎯 Dart imports:
import 'dart:convert';

// 🌎 Project imports:
import 'package:c_school_app/app/data/model/api_request/soe_request.dart';
import 'package:c_school_app/app/data/repository/user_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:supercharged/supercharged.dart';
import 'package:uuid/uuid.dart';
import 'package:pedantic/pedantic.dart';

import '../../core/utils/helper/api_helper.dart';
import '../../data/model/exam/speech_evaluation_result.dart';
import '../../data/model/exam/speech_exam.dart';
import '../../core/service/audio_service.dart';
import '../../core/service/logger_service.dart';
import '../expand_box.dart';

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
  RxList<SentenceInfo> results = <SentenceInfo>[].obs;

  /// Last speech recorded by user
  String? lastSpeechPath;

  final logger = LoggerService.logger;

  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  Rx<RecordingStatus> recordingStatus = RecordingStatus.idle.obs;

  /// Controller to expand or collapse summary
  final summaryExpandController = ExpandBoxController();

  /// TencentApi
  final tencentApiHelper = TencentApiHelper();

  /// Word been selected by user, default to -1
  final RxInt wordSelected = (-1).obs;

  /// ATTENTION: At present this only play the whole speech as timeseries of
  /// audio is not accurate enough.
  void onRefHanziTap(int index) {
    // When ref hanzi is tapped. The index should be count without punctuation.
    // playRefSpeech(wordIndex: exam.refText!.indexWithoutPunctuation(index));
    playRefSpeech();
  }

  /// ATTENTION: At present this only play the whole speech as timeseries of
  /// audio is not accurate enough.
  void onResultHanziTap(int index) {
    if (results.isEmpty || lastSpeechPath == null) return;
    // When hanzi in result is tapped. The index should be count without punctuation.
    // playUserSpeech(wordIndex: exam.refText!.indexWithoutPunctuation(index));
    playUserSpeech();
  }

  /// Play userSpeech. If wordIndex is specified, play the single word
  void playUserSpeech({int? wordIndex}) async {
    var from;
    var to;
    if (lastSpeechPath == null) {
      logger.e('Called when lastSpeechPath is null!');
    }
    if (wordIndex != null) {
      from = results.last.words?[wordIndex].beginTime?.milliseconds;
      to = results.last.words?[wordIndex].endTime?.milliseconds;
      if (from == null || to == null) {
        logger.w('No start or end time found for word index $wordIndex');
        return;
      }
    }
    await audioService.startPlayer(
        uri: lastSpeechPath!, key: '${exam.refText!}:user', from: from, to: to);
  }

  /// Play ref speech of exam. If wordIndex is specified, play the single word
  void playRefSpeech({int? wordIndex}) async {
    var from;
    var to;
    if (wordIndex != null) {
      from = exam.refSpeech!.timeSeries![wordIndex].milliseconds;
      to = exam.refSpeech!.timeSeries!
          .elementAtOrNull(wordIndex + 1)
          ?.milliseconds;
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
    recordingStatus.value = RecordingStatus.recording;
  }

  /// If audio < 1s, the result will not be evaluated
  void _stopRecordAndEvaluate() async {
    if (recordingStatus.value != RecordingStatus.recording) return null;
    recordingStatus.value = RecordingStatus.evaluating;
    final file = await audioService.stopRecorder();
    lastSpeechPath = file.path;
    if (await audioService.durationOfAudio(file.path) < 1.seconds) {
      unawaited(Fluttertoast.showToast(
          msg: 'ui.speech.evaluation.error.speechTooShort'.tr));
      recordingStatus.value = RecordingStatus.idle;
      return;
    }
    final base64 = base64Encode(file.readAsBytesSync());
    final request = SoeRequest(
        ScoreCoeff: Get.find<UserRepository>().currentUser.userScoreCoeff,
        RefText: exam.refTextAsString,
        UserVoiceData: base64,
        SessionId: Uuid().v1());
    recordingStatus.value = RecordingStatus.idle;
    final result = await tencentApiHelper.soe(request, file);
    if (result != null) {
      results.add(result);
    }
  }
}

enum RecordingStatus { recording, evaluating, idle }
