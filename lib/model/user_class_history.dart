import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flutter/cupertino.dart';

part 'user_class_history.flamingo.dart';

class ClassHistory extends Model {
  ClassHistory({
    @required this.classId,
    @required this.timestamp,
    @required this.isLatest,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String classId;
  @Field()
  Timestamp timestamp;
  @Field()
  bool isLatest;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}