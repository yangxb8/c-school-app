// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_class_history.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ClassHistoryKey {
  classId,
  timestamp,
  isLatest,
}

extension ClassHistoryKeyExtension on ClassHistoryKey {
  String get value {
    switch (this) {
      case ClassHistoryKey.classId:
        return 'classId';
      case ClassHistoryKey.timestamp:
        return 'timestamp';
      case ClassHistoryKey.isLatest:
        return 'isLatest';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(ClassHistory doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'classId', doc.classId);
  Helper.writeNotNull(data, 'timestamp', doc.timestamp);
  Helper.writeNotNull(data, 'isLatest', doc.isLatest);

  return data;
}

/// For load data
void _$fromData(ClassHistory doc, Map<String, dynamic> data) {
  doc.classId = Helper.valueFromKey<String>(data, 'classId');
  if (data['timestamp'] is Map) {
    doc.timestamp = Helper.timestampFromMap(data, 'timestamp');
  } else {
    doc.timestamp = Helper.valueFromKey<Timestamp>(data, 'timestamp');
  }

  doc.isLatest = Helper.valueFromKey<bool>(data, 'isLatest');
}
