import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'user_word_history.flamingo.dart';

class WordHistory extends Model {
  WordHistory({
    this.wordId,
    this.timestamp,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String wordId;
  @Field()
  Timestamp timestamp;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}