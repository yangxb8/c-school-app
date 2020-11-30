import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/service/class_service.dart';

part 'class.flamingo.dart';

class CSchoolClass extends Document<CSchoolClass> {
  static ClassService classService = Get.find<ClassService>();

  CSchoolClass({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : classId = id,
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String classId;

  @Field()
  String title;

  @Field()
  String description;

  /// Converted from ClassTag enum
  @Field()
  List<String> _tags;

  /// If the Class has pic in cloud storage
  @StorageField()
  StorageFile pic;

  List<ClassTag> get tags => EnumToString.fromList(ClassTag.values, _tags);

  /// Convert class Id to WordTag and find words related
  List<Word> get words => classService
      .findWordsByTags([EnumToString.fromString(WordTag.values, classId)]);

  int get classViewedCount => classService.classViewedCount(this);

  set tags(List<ClassTag> tags_) => _tags = EnumToString.toList(tags_);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}

enum ClassTag { LEVEL1, LEVEL2, LEVEL3 }
