// 📦 Package imports:

// 🌎 Project imports:
import 'package:c_school_app/app/data/interface/filterable.dart';
import 'package:c_school_app/app/data/repository/exam_repository.dart';
import 'package:c_school_app/app/data/repository/word_repository.dart';
// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';

import './word/word.dart';
import '../interface/searchable.dart';
import '../../core/service/lecture_service.dart';
import 'exam/exam_base.dart';

part 'lecture.flamingo.dart';

class Lecture extends Document<Lecture> with Filterable implements Searchable {
  Lecture({
    String? id,
    int level = 0,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
  })  : lectureId = id,
        level = level,
        tags = id == null ? [] : ['$levelPrefix$level'],
        super(id: id, snapshot: snapshot, values: values);

  static const levelPrefix = 'Level';

  /// For display
  @Field()
  int level = 0;

  @Field()
  String title = '';

  @Field()
  String description = '';

  /// Converted from ClassTag enum
  @Field()
  List<String>? tags = [];

  /// Hash of lecture pic for display by blurhash
  @Field()
  String picHash = '';

  @override
  Map<String, dynamic> get searchableProperties => {
        'title': title,
        'lectureId': lectureId,
        'description': description,
        'level': level.toString(),
        'tags': tags,
      };

  @override
  Map<String, dynamic> get filterableProperties => {
        'lectureId': lectureId,
        'level': level,
        'tags': tags,
      };

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @Field()
  String? lectureId;

  /// If the lecture has pic in cloud storage
  @StorageField()
  StorageFile? pic;

  String get levelForDisplay => '$levelPrefix$level';

  /// 'C0001' => 1
  int get intLectureId => int.parse(lectureId!.numericOnly());
}

extension LectureUtil on Lecture {
  /// find words related
  List<Word> get words =>
      Get.find<WordRepository>().findWordBy({'tags': lectureId});

  /// find exams related
  List<Exam> get exams =>
      Get.find<ExamRepository>().findExamBy({'tags': lectureId});

  int get lectureViewedCount =>
      Get.find<LectureService>().lectureViewedCount(this);
}
