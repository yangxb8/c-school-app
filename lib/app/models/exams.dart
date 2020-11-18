import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:spoken_chinese/exceptions/sound_exceptions.dart';

class SpeechExam extends ExamBase {
  String refText;
  SpeechExamMode mode;

  SpeechExam(
      {@required examId,
      @required title,
      @required lectureId,
      @required question,
      @required questionVoiceData,
      @required this.refText,
      @required this.mode})
      : super(
            examId: examId,
            title: title,
            lectureId: lectureId,
            question: question,
            questionVoiceData: questionVoiceData);

  @override
  ExamType get examType => ExamType.SPEECH;
}

abstract class ExamBase {
  final String examId;
  final String title;
  final String lectureId;
  final String question;
  // Voice data for speech
  final Uint8List _questionVoiceData;

  ExamBase(
      {@required this.examId,
      @required this.title,
      @required this.lectureId,
      @required this.question,
      @required questionVoiceData})
      : _questionVoiceData = questionVoiceData;

  /// ExamType of this exam
  ExamType get examType;

  Uint8List get questionVoice {
    if (_questionVoiceData == null) {
      throw NoVoiceDataException();
    } else {
      return _questionVoiceData;
    }
  }
}

enum ExamType { SPEECH, CHINESE_CHARACTER, SELECT }

enum SpeechExamMode {WORD, SENTENCE, PARAGRAPH, FREE}