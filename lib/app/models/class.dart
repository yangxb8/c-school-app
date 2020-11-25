import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';

class CSchoolClass extends Document<CSchoolClass>{
    CSchoolClass({
    @required id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

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

  set tags(List<ClassTag> tags_) => EnumToString.toList(tags_);
    
}

enum ClassTag{LEVEL1, LEVEL2, LEVEL3}