// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordKey {
  word,
  pinyin,
  meaningJp,
  _examples,
  relatedWordIDs,
  breakdowns,
  synonyms,
  antonyms,
  tags,

  pic,
  wordAudio,
  _examplesAudio,
}

extension WordKeyExtension on WordKey {
  String get value {
    switch (this) {
      case WordKey.word:
        return 'word';
      case WordKey.pinyin:
        return 'pinyin';
      case WordKey.meaningJp:
        return 'meaningJp';
      case WordKey._examples:
        return '_examples';
      case WordKey.relatedWordIDs:
        return 'relatedWordIDs';
      case WordKey.breakdowns:
        return 'breakdowns';
      case WordKey.synonyms:
        return 'synonyms';
      case WordKey.antonyms:
        return 'antonyms';
      case WordKey.tags:
        return 'tags';
      case WordKey.pic:
        return 'pic';
      case WordKey.wordAudio:
        return 'wordAudio';
      case WordKey._examplesAudio:
        return '_examplesAudio';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Word doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'word', doc.word);
  Helper.writeNotNull(data, 'pinyin', doc.pinyin);
  Helper.writeNotNull(data, 'meaningJp', doc.meaningJp);
  Helper.writeNotNull(data, '_examples', doc._examples);
  Helper.writeNotNull(data, 'relatedWordIDs', doc.relatedWordIDs);
  Helper.writeNotNull(data, 'breakdowns', doc.breakdowns);
  Helper.writeNotNull(data, 'synonyms', doc.synonyms);
  Helper.writeNotNull(data, 'antonyms', doc.antonyms);
  Helper.writeNotNull(data, 'tags', doc.tags);

  Helper.writeStorageNotNull(data, 'pic', doc.pic, isSetNull: true);
  Helper.writeStorageNotNull(data, 'wordAudio', doc.wordAudio, isSetNull: true);
  Helper.writeStorageListNotNull(data, '_examplesAudio', doc._examplesAudio,
      isSetNull: true);

  return data;
}

/// For load data
void _$fromData(Word doc, Map<String, dynamic> data) {
  doc.word = Helper.valueListFromKey<String>(data, 'word');
  doc.pinyin = Helper.valueListFromKey<String>(data, 'pinyin');
  doc.meaningJp = Helper.valueListFromKey<String>(data, 'meaningJp');
  doc._examples = Helper.valueMapFromKey<String, String>(data, '_examples');
  doc.relatedWordIDs = Helper.valueListFromKey<String>(data, 'relatedWordIDs');
  doc.breakdowns = Helper.valueListFromKey<String>(data, 'breakdowns');
  doc.synonyms = Helper.valueListFromKey<String>(data, 'synonyms');
  doc.antonyms = Helper.valueListFromKey<String>(data, 'antonyms');
  doc.tags = Helper.valueListFromKey<String>(data, 'tags');

  doc.pic = Helper.storageFile(data, 'pic');
  doc.wordAudio = Helper.storageFile(data, 'wordAudio');
  doc._examplesAudio = Helper.storageFiles(data, '_examplesAudio');
}
