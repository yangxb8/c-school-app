// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_meaning.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordMeaningKey {
  meaning,
  _examples,
  _exampleMeanings,
  _examplePinyins,
  exampleMaleAudioTimeSeries,
  exampleFemaleAudioTimeSeries,

  exampleMaleAudios,
  exampleFemaleAudios,
}

extension WordMeaningKeyExtension on WordMeaningKey {
  String get value {
    switch (this) {
      case WordMeaningKey.meaning:
        return 'meaning';
      case WordMeaningKey._examples:
        return '_examples';
      case WordMeaningKey._exampleMeanings:
        return '_exampleMeanings';
      case WordMeaningKey._examplePinyins:
        return '_examplePinyins';
      case WordMeaningKey.exampleMaleAudioTimeSeries:
        return 'exampleMaleAudioTimeSeries';
      case WordMeaningKey.exampleFemaleAudioTimeSeries:
        return 'exampleFemaleAudioTimeSeries';
      case WordMeaningKey.exampleMaleAudios:
        return 'exampleMaleAudios';
      case WordMeaningKey.exampleFemaleAudios:
        return 'exampleFemaleAudios';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(WordMeaning doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'meaning', doc.meaning);
  Helper.writeNotNull(data, '_examples', doc._examples);
  Helper.writeNotNull(data, '_exampleMeanings', doc._exampleMeanings);
  Helper.writeNotNull(data, '_examplePinyins', doc._examplePinyins);
  Helper.writeNotNull(
      data, 'exampleMaleAudioTimeSeries', doc.exampleMaleAudioTimeSeries);
  Helper.writeNotNull(
      data, 'exampleFemaleAudioTimeSeries', doc.exampleFemaleAudioTimeSeries);

  Helper.writeStorageListNotNull(
      data, 'exampleMaleAudios', doc.exampleMaleAudios,
      isSetNull: true);
  Helper.writeStorageListNotNull(
      data, 'exampleFemaleAudios', doc.exampleFemaleAudios,
      isSetNull: true);

  return data;
}

/// For load data
void _$fromData(WordMeaning doc, Map<String, dynamic> data) {
  doc.meaning = Helper.valueFromKey<String>(data, 'meaning');
  doc._examples = Helper.valueListFromKey<String>(data, '_examples');
  doc._exampleMeanings =
      Helper.valueListFromKey<String>(data, '_exampleMeanings');
  doc._examplePinyins =
      Helper.valueListFromKey<String>(data, '_examplePinyins');
  doc.exampleMaleAudioTimeSeries =
      Helper.valueListFromKey<int>(data, 'exampleMaleAudioTimeSeries');
  doc.exampleFemaleAudioTimeSeries =
      Helper.valueListFromKey<int>(data, 'exampleFemaleAudioTimeSeries');

  doc.exampleMaleAudios = Helper.storageFiles(data, 'exampleMaleAudios');
  doc.exampleFemaleAudios = Helper.storageFiles(data, 'exampleFemaleAudios');
}
