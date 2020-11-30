import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:c_school_app/exceptions/sound_exceptions.dart';
import 'package:c_school_app/service/app_state_service.dart';

import '../../app/models/exams.dart';
import '../../app/models/user_speech.dart';
import '../../service/api_service.dart';

class SpeechRecordingController extends GetxController {
  static const platform = MethodChannel('soe');
  /// If recording, won't response to touch other than stopRecorder
  /// If in evaluation, won't response to any touch
  final Rx<RecordingStatus> recordingStatus = RecordingStatus.IDLE.obs;
  /// User can record as many times as they like.
  final RxList<UserSpeech> userSpeeches = <UserSpeech>[].obs;
  /// Word been selected by user, default to 0 (first word in exam.question)
  final RxInt wordSelected = 0.obs;
  /// Exam this SpeechExamBottomSheet should control.
  SpeechExam exam;
  /// Used to play question and user speech
  AudioPlayer _myPlayer;

  /// Return last speech by user
  UserSpeech get lastSpeech => userSpeeches.isEmpty? null: userSpeeches.last;

  @override
  Future<void> onInit() async {
    // Reuse player
    _myPlayer = await AudioPlayer(playerId: 'SINGLETON');
    AudioPlayer.logEnabled = Get.find<AppStateService>().isDebug;
    super.onInit();
  }

  void initWithExam(SpeechExam exam) {
    this.exam = exam;
  }

  void startRecord() async {
    assert(!exam.isNull);
    // Verify permission
    if (recordingStatus.value != RecordingStatus.IDLE) return;
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw RecordingPermissionException();
    }
    recordingStatus(RecordingStatus.RECORDING);
    // create new UserSpeech instance
    var newSpeech = await UserSpeech.forExam(exam: exam).init();
    userSpeeches.add(newSpeech);
    // Call native method
    await Get.find<ApiService>().tencentApi.soeStartRecord(exam);
  }

  void stopRecordAndEvaluate() async {
    recordingStatus(RecordingStatus.EVALUATING);
    // Call native method and save result to latest userSpeech instance
    var result = await Get.find<ApiService>().tencentApi.soeStopRecordAndEvaluate();
    userSpeeches.last.speechData = result['speechData'];
    userSpeeches.last.evaluationResult = result['evaluationResult'];
    // Save result to firestore
    Get.find<ApiService>()
        .firestoreApi
        .saveUserSpeechResult(userSpeeches.last);
    recordingStatus(RecordingStatus.IDLE);
  }

  void playQuestion() async {
    _playFromBuffer(exam.questionVoice);
  }

  /// Use can try as many time as their like.
  /// Trial start from 1.
  void playUserSpeech({int trial = 1}) async {
    _playFromBuffer(await userSpeeches[trial - 1].speechData);
  }

  void _playFromBuffer(Uint8List buffer) async {
    // If recording, do nothing
    if ((recordingStatus.value != RecordingStatus.IDLE)) return;
    // If already playing, stop it and play selected buffer.
    await _myPlayer.stop();
    await _myPlayer.playBytes(buffer);
  }

  /// Ensure resource are released
  @override
  void onClose() {
    if (_myPlayer != null) {
      _myPlayer = null;
    }
    super.onClose();
  }

  void handleRecordButtonPressed() {
    switch(recordingStatus.value){
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
