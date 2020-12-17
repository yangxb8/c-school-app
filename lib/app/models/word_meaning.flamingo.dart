// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_meaning.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordMeaningKey {
  meaning,
  examples,
  exampleMeanings,
  examplePinyins,

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
      case WordMeaningKey._exampleMaleAudios:
        return '_exampleMaleAudios';
      case WordMeaningKey._exampleFemaleAudios:
        return '_exampleFemaleAudios';
      default:
        return null;
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

  Helper.writeStorageListNotNull(
      data, '_exampleMaleAudios', doc._exampleMaleAudios,
      isSetNull: true);
  Helper.writeStorageListNotNull(
      data, '_exampleFemaleAudios', doc._exampleFemaleAudios,
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

  doc._exampleMaleAudios = Helper.storageFiles(data, '_exampleMaleAudios');
  doc._exampleFemaleAudios = Helper.storageFiles(data, '_exampleFemaleAudios');
}
