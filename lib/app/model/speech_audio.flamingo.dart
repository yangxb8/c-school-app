// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_audio.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum SpeechAudioKey {
  timeSeries,

  audio,
}

extension SpeechAudioKeyExtension on SpeechAudioKey {
  String get value {
    switch (this) {
      case SpeechAudioKey.timeSeries:
        return 'timeSeries';
      case SpeechAudioKey.audio:
        return 'audio';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(SpeechAudio doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'timeSeries', doc.timeSeries);

  Helper.writeStorageNotNull(data, 'audio', doc.audio, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(SpeechAudio doc, Map<String, dynamic> data) {
  doc.timeSeries = Helper.valueListFromKey<int>(data, 'timeSeries');

  doc.audio = Helper.storageFile(data, 'audio');
}
