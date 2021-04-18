// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_meaning.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordMeaningKey {
  meaning,
  examples,
}

extension WordMeaningKeyExtension on WordMeaningKey {
  String get value {
    switch (this) {
      case WordMeaningKey.meaning:
        return 'meaning';
      case WordMeaningKey.examples:
        return 'examples';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(WordMeaning doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'meaning', doc.meaning);

  Helper.writeModelListNotNull(data, 'examples', doc.examples);

  return data;
}

/// For load data
void _$fromData(WordMeaning doc, Map<String, dynamic> data) {
  doc.meaning = Helper.valueFromKey<String?>(data, 'meaning');

  final _examples =
      Helper.valueMapListFromKey<String, dynamic>(data, 'examples');
  if (_examples != null) {
    doc.examples = _examples
        .where((d) => d != null)
        .map((d) => WordExample(values: d))
        .toList();
  } else {
    doc.examples = null;
  }
}
