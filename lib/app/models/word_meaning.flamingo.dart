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

  _exampleAudios,
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
      case WordMeaningKey._exampleAudios:
        return '_exampleAudios';
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

  Helper.writeStorageListNotNull(data, '_exampleAudios', doc._exampleAudios,
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

  doc._exampleAudios = Helper.storageFiles(data, '_exampleAudios');
}
