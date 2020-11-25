import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'word.flamingo.dart';

class Word extends Document<Word>{
  Word({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String word;

  @Field()
  String pinyin;

  /// Sentence examples of this word
  @Field()
  List<String> examples;

  @Field()
  List<String> relatedWordsInExample;

  /// 拆字
  @Field()
  List<String> breakdowns;

  @Field()
  List<String> synonyms;

  @Field()
  List<String> antonyms;

  /// Converted from WordTag enum
  @Field()
  List<String> tags;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  bool get isSingleCharacterWord => word.length == 1;

  /// 对于一般的词，不存在多音。但对于单字（这里理解为单字构成的词），存在多音现象。
  /// 这时即使word相同，pinyin不同也认为是两个词
  @override
  bool operator == (other) {
    if(!other is Word) return false;
    if(isSingleCharacterWord) {
      return word == other.word;
    } else {
     return  word == other.word && pinyin == other.pinyin;
    }
  }
}

enum WordTag{
  // C = Class
  C1, C2, C3, C4, C5, C6, C7, C8, C9, C10,
  HSK1, HSK2, HSK3, HSK4
}