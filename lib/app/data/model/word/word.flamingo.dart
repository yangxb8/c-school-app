// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordKey {
  word,
  pinyin,
  explanation,
  partOfSentence,
  hint,
  _relatedWordIds,
  _otherMeaningIds,
  breakdowns,
  tags,
  picHash,
  wordId,
  wordMeanings,
  wordAudioMale,
  wordAudioFemale,
  pic,
}

extension WordKeyExtension on WordKey {
  String get value {
    switch (this) {
      case WordKey.word:
        return 'word';
      case WordKey.pinyin:
        return 'pinyin';
      case WordKey.explanation:
        return 'explanation';
      case WordKey.partOfSentence:
        return 'partOfSentence';
      case WordKey.hint:
        return 'hint';
      case WordKey._relatedWordIds:
        return '_relatedWordIds';
      case WordKey._otherMeaningIds:
        return '_otherMeaningIds';
      case WordKey.breakdowns:
        return 'breakdowns';
      case WordKey.tags:
        return 'tags';
      case WordKey.picHash:
        return 'picHash';
      case WordKey.wordId:
        return 'wordId';
      case WordKey.wordMeanings:
        return 'wordMeanings';
      case WordKey.wordAudioMale:
        return 'wordAudioMale';
      case WordKey.wordAudioFemale:
        return 'wordAudioFemale';
      case WordKey.pic:
        return 'pic';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Word doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'word', doc.word);
  Helper.writeNotNull(data, 'pinyin', doc.pinyin);
  Helper.writeNotNull(data, 'explanation', doc.explanation);
  Helper.writeNotNull(data, 'partOfSentence', doc.partOfSentence);
  Helper.writeNotNull(data, 'hint', doc.hint);
  Helper.writeNotNull(data, '_relatedWordIds', doc._relatedWordIds);
  Helper.writeNotNull(data, '_otherMeaningIds', doc._otherMeaningIds);
  Helper.writeNotNull(data, 'breakdowns', doc.breakdowns);
  Helper.writeNotNull(data, 'tags', doc.tags);
  Helper.writeNotNull(data, 'picHash', doc.picHash);
  Helper.writeNotNull(data, 'wordId', doc.wordId);

  Helper.writeModelListNotNull(data, 'wordMeanings', doc.wordMeanings);
  Helper.writeModelNotNull(data, 'wordAudioMale', doc.wordAudioMale);
  Helper.writeModelNotNull(data, 'wordAudioFemale', doc.wordAudioFemale);

  Helper.writeStorageNotNull(data, 'pic', doc.pic, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(Word doc, Map<String, dynamic> data) {
  doc.word = Helper.valueListFromKey<String>(data, 'word');
  doc.pinyin = Helper.valueListFromKey<String>(data, 'pinyin');
  doc.explanation = Helper.valueFromKey<String?>(data, 'explanation');
  doc.partOfSentence = Helper.valueFromKey<String?>(data, 'partOfSentence');
  doc.hint = Helper.valueFromKey<String?>(data, 'hint');
  doc._relatedWordIds =
      Helper.valueListFromKey<String>(data, '_relatedWordIds');
  doc._otherMeaningIds =
      Helper.valueListFromKey<String>(data, '_otherMeaningIds');
  doc.breakdowns = Helper.valueListFromKey<String>(data, 'breakdowns');
  doc.tags = Helper.valueListFromKey<String>(data, 'tags');
  doc.picHash = Helper.valueFromKey<String?>(data, 'picHash');
  doc.wordId = Helper.valueFromKey<String?>(data, 'wordId');

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

  final _wordAudioMale =
      Helper.valueMapFromKey<String, dynamic>(data, 'wordAudioMale');
  if (_wordAudioMale != null) {
    doc.wordAudioMale = SpeechAudio(values: _wordAudioMale);
  } else {
    doc.wordAudioMale = null;
  }

  final _wordAudioFemale =
      Helper.valueMapFromKey<String, dynamic>(data, 'wordAudioFemale');
  if (_wordAudioFemale != null) {
    doc.wordAudioFemale = SpeechAudio(values: _wordAudioFemale);
  } else {
    doc.wordAudioFemale = null;
  }

  doc.pic = Helper.storageFile(data, 'pic');
}