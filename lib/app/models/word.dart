import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flutter/foundation.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> {
  Word({
    @required id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  /// Example: [['我'],[们]]
  @Field()
  List<String> word;

  /// Example: [['wo'],['men']]
  @Field()
  List<String> pinyin;

  /// 日语意思
  @Field()
  List<String> meaningJp;

  /// Sentence examples of this word
  /// '意思': '例句1#例句2#例句3...'的形式
  @Field()
  Map<String, String> _examples;

  /// related word in examples
  @Field()
  List<String> relatedWordIDs;

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

  /// If the word has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// If the word has wordAudio in cloud storage
  @StorageField()
  StorageFile wordAudio;

  /// If the examples has wordAudio for different meaning
  /// a null is used to separate different meaning
  @StorageField()
  List<StorageFile> _examplesAudio;

  Map<String, List<StorageFile>> _examplesAudioMap;

  Map<String, List<String>> get examples =>
      _examples.map((key, value) => MapEntry(key, value.split('#')));

  Map<String, List<StorageFile>> get examplesAudio {
    if(_examplesAudioMap != null) return _examplesAudioMap;
    var meaningIndex = 0;
    _examplesAudioMap = {};
    _examplesAudio?.forEach((exampleAudio) {
      if(exampleAudio == null) {
        meaningIndex++;
      } else {
        if(_examplesAudioMap[meaningJp[meaningIndex]] == null){
          _examplesAudioMap[meaningJp[meaningIndex]] = [exampleAudio];
        } else {
          _examplesAudioMap[meaningJp[meaningIndex]].add(exampleAudio);
        }
      }
    });
    return _examplesAudioMap;
  }

  /// For debug use only!!!
  set examples(Map<String, List<String>> examples_) {
    _examples = examples_.map((key, value) => MapEntry(key, value.join('#')));
  }

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}

enum WordTag {
  // C = Class
  C0001,
  C0002,
  C0003,
  C0004,
  C0005,
  C0006,
  C0007,
  C0008,
  C0009,
  C0010,
  HSK1,
  HSK2,
  HSK3,
  HSK4
}
