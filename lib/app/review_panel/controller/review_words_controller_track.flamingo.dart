// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_words_controller_track.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ReviewWordsControllerTrackKey {
  trackedWordId,
}

extension ReviewWordsControllerTrackKeyExtension
    on ReviewWordsControllerTrackKey {
  String get value {
    switch (this) {
      case ReviewWordsControllerTrackKey.trackedWordId:
        return 'trackedWordId';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(ReviewWordsControllerTrack doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'trackedWordId', doc.trackedWordId);

  return data;
}

/// For load data
void _$fromData(ReviewWordsControllerTrack doc, Map<String, dynamic> data) {
  doc.trackedWordId = Helper.valueFromKey<String>(data, 'trackedWordId');
}
