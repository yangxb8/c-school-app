// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordKey {
  word,
  pinyin,
  examples,
  relatedWordsInExample,
  breakdowns,
  synonyms,
  antonyms,
  tags,
}

extension WordKeyExtension on WordKey {
  String get value {
    switch (this) {
      case WordKey.word:
        return 'word';
      case WordKey.pinyin:
        return 'pinyin';
      case WordKey.examples:
        return 'examples';
      case WordKey.relatedWordsInExample:
        return 'relatedWordsInExample';
      case WordKey.breakdowns:
        return 'breakdowns';
      case WordKey.synonyms:
        return 'synonyms';
      case WordKey.antonyms:
        return 'antonyms';
      case WordKey.tags:
        return 'tags';
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
  Helper.writeNotNull(data, 'examples', doc.examples);
  Helper.writeNotNull(data, 'relatedWordsInExample', doc.relatedWordsInExample);
  Helper.writeNotNull(data, 'breakdowns', doc.breakdowns);
  Helper.writeNotNull(data, 'synonyms', doc.synonyms);
  Helper.writeNotNull(data, 'antonyms', doc.antonyms);
  Helper.writeNotNull(data, 'tags', doc.tags);

  return data;
}

/// For load data
void _$fromData(Word doc, Map<String, dynamic> data) {
  doc.word = Helper.valueFromKey<String>(data, 'word');
  doc.pinyin = Helper.valueFromKey<String>(data, 'pinyin');
  doc.examples = Helper.valueListFromKey<String>(data, 'examples');
  doc.relatedWordsInExample =
      Helper.valueListFromKey<String>(data, 'relatedWordsInExample');
  doc.breakdowns = Helper.valueListFromKey<String>(data, 'breakdowns');
  doc.synonyms = Helper.valueListFromKey<String>(data, 'synonyms');
  doc.antonyms = Helper.valueListFromKey<String>(data, 'antonyms');
  doc.tags = Helper.valueListFromKey<String>(data, 'tags');
}
