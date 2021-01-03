import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/service/lecture_service.dart';

part 'lecture.flamingo.dart';

class Lecture extends Document<Lecture>{
  static const levelPrefix = 'Level';
  static LectureService lectureService = Get.find<LectureService>();

  Lecture({
    String id,
    int level,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : lectureId = id,
        level = level,
        tags = id.isNull? []:['$levelPrefix$level'],
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String lectureId;

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

  /// Hash of lecture pic for display by blurhash
  @Field()
  String picHash;

  /// If the lecture has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// Convert lecture Id to WordTag and find words related
  List<Word> get words => lectureService
      .findWordsByTags([lectureId]);
  int get lectureViewedCount => lectureService.lectureViewedCount(this);
  String get levelForDisplay => '$levelPrefix$level';

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
