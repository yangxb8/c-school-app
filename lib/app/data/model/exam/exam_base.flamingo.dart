// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_base.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum ExamKey {
  title,
  question,
  examId,
  tags,
  _examType,
}

extension ExamKeyExtension on ExamKey {
  String get value {
    switch (this) {
      case ExamKey.title:
        return 'title';
      case ExamKey.question:
        return 'question';
      case ExamKey.examId:
        return 'examId';
      case ExamKey.tags:
        return 'tags';
      case ExamKey._examType:
        return '_examType';
      default:
        throw Exception('Invalid data key.');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(Exam doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'title', doc.title);
  Helper.writeNotNull(data, 'question', doc.question);
  Helper.writeNotNull(data, 'examId', doc.examId);
  Helper.writeNotNull(data, 'tags', doc.tags);
  Helper.writeNotNull(data, '_examType', doc._examType);

  return data;
}

/// For load data
void _$fromData(Exam doc, Map<String, dynamic> data) {
  doc.title = Helper.valueFromKey<String>(data, 'title');
  doc.question = Helper.valueFromKey<String>(data, 'question');
  doc.examId = Helper.valueFromKey<String?>(data, 'examId');
  doc.tags = Helper.valueListFromKey<String>(data, 'tags');
  doc._examType = Helper.valueFromKey<String>(data, '_examType');
}