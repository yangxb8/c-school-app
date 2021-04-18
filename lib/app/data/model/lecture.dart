// 📦 Package imports:

// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/core/utils/filterable.dart';
import 'package:c_school_app/app/data/repository/exam_repository.dart';
import 'package:c_school_app/app/data/repository/word_repository.dart';
import '../service/lecture_service.dart';
import '../../core/utils/searchable.dart';
import './word/word.dart';
import 'exam/exam_base.dart';

part 'lecture.flamingo.dart';

class Lecture extends Document<Lecture> with Filterable implements Searchable {
  static const levelPrefix = 'Level';

  Lecture({
    String? id,
    int level = 0,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
  })  : lectureId = id,
        level = level,
        tags = id == null ? [] : ['$levelPrefix$level'],
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String? lectureId;

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

  /// If the lecture has pic in cloud storage
  @StorageField()
  StorageFile? pic;

  String get levelForDisplay => '$levelPrefix$level';

  /// 'C0001' => 1
  int get intLectureId => int.parse(lectureId!.numericOnly());

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

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
