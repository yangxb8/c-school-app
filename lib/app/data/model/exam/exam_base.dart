// 📦 Package imports:
// 🌎 Project imports:
import 'package:c_school_app/app/core/utils/filterable.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'speech_exam.dart';

part 'exam_base.flamingo.dart';

/// Exam base, extends this class to make different exam
class Exam<T> extends Document<Exam<T>> with Filterable {
  Exam({
    String? id,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
  })  : examId = id,
        tags = id == null ? const [] : [id.split('-').first],
        _examType = T.toString(), // Assign lectureId to tags
        super(id: id, snapshot: snapshot, values: values);

  /// Create instance of subclass by snapshot
  factory Exam.fromSnapshot(DocumentSnapshot snapshot) =>
      _factories[snapshot.data()!['_examType']]!(snapshot) as Exam<T>;

  /// Hold information about exam extends this class, need to be updated by hand
  static final Map<String, Object Function(DocumentSnapshot snapshot)>
      _factories = {'SpeechExam': (snapshot) => SpeechExam(snapshot: snapshot)};

  @Field()
  String title = '';

  @Field()
  String question = '';

  @override
  Map<String, dynamic> get filterableProperties =>
      {'examId': examId, 'tags': tags};

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @Field()
  String? examId;

  @Field()
  List<String>? tags;

  @Field()
  String _examType;

  String get lectureId => examId!.split('-').first;
}
