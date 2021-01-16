// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_speech.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum UserSpeechKey {
  speechId,
  speeches,
}

extension UserSpeechKeyExtension on UserSpeechKey {
  String get value {
    switch (this) {
      case UserSpeechKey.speechId:
        return 'speechId';
      case UserSpeechKey.speeches:
        return 'speeches';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(UserSpeech doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'speechId', doc.speechId);

  Helper.writeModelListNotNull(data, 'speeches', doc.speeches);

  return data;
}

/// For load data
void _$fromData(UserSpeech doc, Map<String, dynamic> data) {
  doc.speechId = Helper.valueFromKey<String>(data, 'speechId');

  final _speeches =
      Helper.valueMapListFromKey<String, dynamic>(data, 'speeches');
  if (_speeches != null) {
    doc.speeches = _speeches
        .where((d) => d != null)
        .map((d) => Speech(values: d))
        .toList();
  } else {
    doc.speeches = null;
  }
}

/// Field value key
enum SpeechKey {
  evaluationResultRaw,

  speechData,
}

extension SpeechKeyExtension on SpeechKey {
  String get value {
    switch (this) {
      case SpeechKey.evaluationResultRaw:
        return 'evaluationResultRaw';
      case SpeechKey.speechData:
        return 'speechData';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Speech doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'evaluationResultRaw', doc.evaluationResultRaw);

  Helper.writeStorageNotNull(data, 'speechData', doc.speechData,
      isSetNull: true);

  return data;
}

/// For load data
void _$fromData(Speech doc, Map<String, dynamic> data) {
  doc.evaluationResultRaw =
      Helper.valueFromKey<String>(data, 'evaluationResultRaw');

  doc.speechData = Helper.storageFile(data, 'speechData');
}
