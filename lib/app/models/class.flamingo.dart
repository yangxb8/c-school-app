// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum CSchoolClassKey {
  classId,
  level,
  title,
  description,
  tags,
  picHash,

  pic,
}

extension CSchoolClassKeyExtension on CSchoolClassKey {
  String get value {
    switch (this) {
      case CSchoolClassKey.classId:
        return 'classId';
      case CSchoolClassKey.level:
        return 'level';
      case CSchoolClassKey.title:
        return 'title';
      case CSchoolClassKey.description:
        return 'description';
      case CSchoolClassKey.tags:
        return 'tags';
      case CSchoolClassKey.picHash:
        return 'picHash';
      case CSchoolClassKey.pic:
        return 'pic';
      default:
        return null;
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(CSchoolClass doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'classId', doc.classId);
  Helper.writeNotNull(data, 'level', doc.level);
  Helper.writeNotNull(data, 'title', doc.title);
  Helper.writeNotNull(data, 'description', doc.description);
  Helper.writeNotNull(data, 'tags', doc.tags);
  Helper.writeNotNull(data, 'picHash', doc.picHash);

  Helper.writeStorageNotNull(data, 'pic', doc.pic, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(CSchoolClass doc, Map<String, dynamic> data) {
  doc.classId = Helper.valueFromKey<String>(data, 'classId');
  doc.level = Helper.valueFromKey<int>(data, 'level');
  doc.title = Helper.valueFromKey<String>(data, 'title');
  doc.description = Helper.valueFromKey<String>(data, 'description');
  doc.tags = Helper.valueListFromKey<String>(data, 'tags');
  doc.picHash = Helper.valueFromKey<String>(data, 'picHash');

  doc.pic = Helper.storageFile(data, 'pic');
}
