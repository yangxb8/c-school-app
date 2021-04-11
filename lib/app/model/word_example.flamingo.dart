// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_example.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordExampleKey {
  example,
  meaning,
  pinyin,
  audioMale,
  audioFemale,
}

extension WordExampleKeyExtension on WordExampleKey {
  String get value {
    switch (this) {
      case WordExampleKey.example:
        return 'example';
      case WordExampleKey.meaning:
        return 'meaning';
      case WordExampleKey.pinyin:
        return 'pinyin';
      case WordExampleKey.audioMale:
        return 'audioMale';
      case WordExampleKey.audioFemale:
        return 'audioFemale';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(WordExample doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'example', doc.example);
  Helper.writeNotNull(data, 'meaning', doc.meaning);
  Helper.writeNotNull(data, 'pinyin', doc.pinyin);

  Helper.writeModelNotNull(data, 'audioMale', doc.audioMale);
  Helper.writeModelNotNull(data, 'audioFemale', doc.audioFemale);

  return data;
}

/// For load data
void _$fromData(WordExample doc, Map<String, dynamic> data) {
  doc.example = Helper.valueFromKey<String?>(data, 'example');
  doc.meaning = Helper.valueFromKey<String?>(data, 'meaning');
  doc.pinyin = Helper.valueListFromKey<String>(data, 'pinyin');

  final _audioMale = Helper.valueMapFromKey<String, dynamic>(data, 'audioMale');
  if (_audioMale != null) {
    doc.audioMale = SpeechAudio(values: _audioMale);
  } else {
    doc.audioMale = null;
  }

  final _audioFemale =
      Helper.valueMapFromKey<String, dynamic>(data, 'audioFemale');
  if (_audioFemale != null) {
    doc.audioFemale = SpeechAudio(values: _audioFemale);
  } else {
    doc.audioFemale = null;
  }
}
