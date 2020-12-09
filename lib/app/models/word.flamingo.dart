// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordKey {
  wordId,
  word,
  pinyin,
  hint,
  _relatedWordIDs,
  breakdowns,
  _tags,
  wordMeanings,
  pic,
  wordAudio,
}

extension WordKeyExtension on WordKey {
  String get value {
    switch (this) {
      case WordKey.wordId:
        return 'wordId';
      case WordKey.word:
        return 'word';
      case WordKey.pinyin:
        return 'pinyin';
      case WordKey.hint:
        return 'hint';
      case WordKey._relatedWordIDs:
        return '_relatedWordIDs';
      case WordKey.breakdowns:
        return 'breakdowns';
      case WordKey._tags:
        return '_tags';
      case WordKey.wordMeanings:
        return 'wordMeanings';
      case WordKey.pic:
        return 'pic';
      case WordKey.wordAudio:
        return 'wordAudio';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Word doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'wordId', doc.wordId);
  Helper.writeNotNull(data, 'word', doc.word);
  Helper.writeNotNull(data, 'pinyin', doc.pinyin);
  Helper.writeNotNull(data, 'hint', doc.hint);
  Helper.writeNotNull(data, '_relatedWordIDs', doc._relatedWordIDs);
  Helper.writeNotNull(data, 'breakdowns', doc.breakdowns);
  Helper.writeNotNull(data, '_tags', doc._tags);

  Helper.writeModelListNotNull(data, 'wordMeanings', doc.wordMeanings);

  Helper.writeStorageNotNull(data, 'pic', doc.pic, isSetNull: true);
  Helper.writeStorageNotNull(data, 'wordAudio', doc.wordAudio, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(Word doc, Map<String, dynamic> data) {
  doc.wordId = Helper.valueFromKey<String>(data, 'wordId');
  doc.word = Helper.valueListFromKey<String>(data, 'word');
  doc.pinyin = Helper.valueListFromKey<String>(data, 'pinyin');
  doc.hint = Helper.valueFromKey<String>(data, 'hint');
  doc._relatedWordIDs =
      Helper.valueListFromKey<String>(data, '_relatedWordIDs');
  doc.breakdowns = Helper.valueListFromKey<String>(data, 'breakdowns');
  doc._tags = Helper.valueListFromKey<String>(data, '_tags');

  final _wordMeanings =
      Helper.valueMapListFromKey<String, dynamic>(data, 'wordMeanings');
  if (_wordMeanings != null) {
    doc.wordMeanings = _wordMeanings
        .where((d) => d != null)
        .map((d) => WordMeaning(values: d))
        .toList();
  } else {
    doc.wordMeanings = null;
  }

  doc.pic = Helper.storageFile(data, 'pic');
  doc.wordAudio = Helper.storageFile(data, 'wordAudio');
}
