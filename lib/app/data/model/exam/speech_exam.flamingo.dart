// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_exam.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum SpeechExamKey {
  refText,
  refPinyins,
  _mode,
  refSpeech,
}

extension SpeechExamKeyExtension on SpeechExamKey {
  String get value {
    switch (this) {
      case SpeechExamKey.refText:
        return 'refText';
      case SpeechExamKey.refPinyins:
        return 'refPinyins';
      case SpeechExamKey._mode:
        return '_mode';
      case SpeechExamKey.refSpeech:
        return 'refSpeech';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(SpeechExam doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'refText', doc.refText);
  Helper.writeNotNull(data, 'refPinyins', doc.refPinyins);
  Helper.writeNotNull(data, '_mode', doc._mode);

  Helper.writeModelNotNull(data, 'refSpeech', doc.refSpeech);

  return data;
}

/// For load data
void _$fromData(SpeechExam doc, Map<String, dynamic> data) {
  doc.refText = Helper.valueListFromKey<String>(data, 'refText');
  doc.refPinyins = Helper.valueListFromKey<String>(data, 'refPinyins');
  doc._mode = Helper.valueFromKey<String?>(data, '_mode');

  final _refSpeech = Helper.valueMapFromKey<String, dynamic>(data, 'refSpeech');
  if (_refSpeech != null) {
    doc.refSpeech = SpeechAudio(values: _refSpeech);
  } else {
    doc.refSpeech = null;
  }
}
