import 'package:c_school_app/app/models/class_entity_interface.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/class_service.dart';

part 'class.flamingo.dart';

class CSchoolClass extends Document<CSchoolClass> implements ClassEntityInterface{
  static const levelPrefix = 'Level';
  static ClassService classService = Get.find<ClassService>();

  CSchoolClass({
    String id,
    int level,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : classId = id,
        level = level,
        tags = id.isNull? []:['$levelPrefix$level'],
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String classId;

  /// For display
  @Field()
  int level;

  @Field()
  String title;

  @Field()
  String description;

  /// Converted from ClassTag enum
  @Field()
  List<String> tags;

  /// Hash of class pic for display by blurhash
  @Field()
  String picHash;

  /// If the Class has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// Convert class Id to WordTag and find words related
  List<Word> get words => classService
      .findWordsByTags([classId]);
  int get classViewedCount => classService.classViewedCount(this);
  String get levelForDisplay => '$levelPrefix$level';

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
