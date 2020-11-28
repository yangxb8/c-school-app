//TODO: implement this
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/service/user_service.dart';

import '../../app/models/exams.dart';
import '../../service/api_service.dart';
import '../../service/app_state_service.dart';
import 'speech_evaluation_result.dart';

class UserSpeech {
  /// User this speech belong to.
  String userId;

  /// Lecture this speech belong to. If free speech, lectureID='freeSpeech'.
  String lectureId;

  /// Exam this speech belong to. If free speech, examID='0'
  String examId;

  /// trial=1,2,3.. as user can record speech for same exam as many times as they like
  int trial;

  /// Exam this speech is recorded for. Null If freeSpeech.
  final SpeechExam exam;

  /// Speech Data
  Uint8List speechData;

  /// Evaluation result of this speech
  SpeechEvaluationResult evaluationResult;

  /// Remember to call init()!!
  /// When created from free speech, pass null as exam
  factory UserSpeech.forExam({@required SpeechExam exam}) {
    return UserSpeech._internal(exam, UserService.user.userId,
        exam?.lectureId ?? 'freeSpeech', exam?.examId ?? '0');
  }

  UserSpeech._internal(this.exam, this.userId, this.lectureId, this.examId);

  /// {userID_lectureID_examID}
  String get speechFingerprint => '${userId}_${lectureId}_${examId}';

  Future<UserSpeech> init() async {
    trial = await Get.find<ApiService>()
            .firestoreApi
            .countUserSpeechByFingerprint(speechFingerprint) +
        1; // Trial start from 1 instead of 0.
    return this;
  }

  Future<Uint8List> downloadSpeechData() async => await Get.find<ApiService>()
      .firestoreApi.getUserSpeechByFingerprintAndTrial(fingerPrint: speechFingerprint, trial:trial);
}
