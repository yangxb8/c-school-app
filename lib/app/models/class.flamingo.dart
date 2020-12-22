// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum CSchoolClassKey {
  classId,
  _level,
  title,
  description,
  _tags,
  picHash,

  pic,
}

extension CSchoolClassKeyExtension on CSchoolClassKey {
  String get value {
    switch (this) {
      case CSchoolClassKey.classId:
        return 'classId';
      case CSchoolClassKey._level:
        return '_level';
      case CSchoolClassKey.title:
        return 'title';
      case CSchoolClassKey.description:
        return 'description';
      case CSchoolClassKey._tags:
        return '_tags';
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
  Helper.writeNotNull(data, '_level', doc._level);
  Helper.writeNotNull(data, 'title', doc.title);
  Helper.writeNotNull(data, 'description', doc.description);
  Helper.writeNotNull(data, '_tags', doc._tags);
  Helper.writeNotNull(data, 'picHash', doc.picHash);

  Helper.writeStorageNotNull(data, 'pic', doc.pic, isSetNull: true);

  return data;
}

/// For load data
void _$fromData(CSchoolClass doc, Map<String, dynamic> data) {
  doc.classId = Helper.valueFromKey<String>(data, 'classId');
  doc._level = Helper.valueFromKey<String>(data, '_level');
  doc.title = Helper.valueFromKey<String>(data, 'title');
  doc.description = Helper.valueFromKey<String>(data, 'description');
  doc._tags = Helper.valueListFromKey<String>(data, '_tags');
  doc.picHash = Helper.valueFromKey<String>(data, 'picHash');

  doc.pic = Helper.storageFile(data, 'pic');
}
