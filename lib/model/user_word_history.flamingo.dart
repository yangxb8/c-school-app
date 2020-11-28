// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_word_history.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum WordHistoryKey {
  wordId,
  timestamp,
}

extension WordHistoryKeyExtension on WordHistoryKey {
  String get value {
    switch (this) {
      case WordHistoryKey.wordId:
        return 'wordId';
      case WordHistoryKey.timestamp:
        return 'timestamp';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(WordHistory doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'wordId', doc.wordId);
  Helper.writeNotNull(data, 'timestamp', doc.timestamp);

  return data;
}

/// For load data
void _$fromData(WordHistory doc, Map<String, dynamic> data) {
  doc.wordId = Helper.valueFromKey<String>(data, 'wordId');
  if (data['timestamp'] is Map) {
    doc.timestamp = Helper.timestampFromMap(data, 'timestamp');
  } else {
    doc.timestamp = Helper.valueFromKey<Timestamp>(data, 'timestamp');
  }
}
