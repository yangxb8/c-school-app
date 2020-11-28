import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'user_class_history.flamingo.dart';

class ClassHistory extends Model {
  ClassHistory({
    this.classId,
    this.timestamp,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String classId;
  @Field()
  Timestamp timestamp;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}