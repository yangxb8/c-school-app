import 'package:enum_to_string/enum_to_string.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:spoken_chinese/app/models/word.dart';

part 'user_word_history.flamingo.dart';

class WordHistory extends Model {
  WordHistory({
    @required this.wordId,
    @required WordMemoryStatus wordMemoryStatus,
    @required this.timestamp,
    @required this.isLatest,
    Map<String, dynamic> values,
  })  : _wordMemoryStatus = EnumToString.convertToString(wordMemoryStatus),
        super(values: values);

  @Field()
  String wordId;
  @Field()
  // ignore: prefer_final_fields
  String _wordMemoryStatus;
  @Field()
  Timestamp timestamp;
  @Field()
  bool isLatest;

  WordMemoryStatus get wordMemoryStatus =>
      EnumToString.fromString(WordMemoryStatus.values, _wordMemoryStatus);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
