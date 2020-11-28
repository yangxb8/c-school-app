import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/exceptions/sound_exceptions.dart';
import 'package:spoken_chinese/service/class_service.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> {
  Word({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : wordId = id,
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String wordId;

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
  List<String> _relatedWordIDs;

  /// 拆字
  @Field()
  List<String> breakdowns;

  @Field()
  List<String> synonyms;

  @Field()
  List<String> antonyms;

  /// Converted from WordTag enum
  @Field()
  List<String> _tags;

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

  List<Word> get relatedWords =>
      Get.find<ClassService>().findWordsByIds(_relatedWordIDs);

  Map<String, List<String>> get examples =>
      _examples.map((key, value) => MapEntry(key, value.split('#')));

  String get classId => id.split('-').first;

  Map<String, List<StorageFile>> get examplesAudio {
    if (_examplesAudioMap != null) return _examplesAudioMap;
    var meaningIndex = 0;
    _examplesAudioMap = {};
    _examplesAudio?.forEach((exampleAudio) {
      if (exampleAudio == null) {
        meaningIndex++;
      } else {
        if (_examplesAudioMap[meaningJp[meaningIndex]] == null) {
          _examplesAudioMap[meaningJp[meaningIndex]] = [exampleAudio];
        } else {
          _examplesAudioMap[meaningJp[meaningIndex]].add(exampleAudio);
        }
      }
    });
    return _examplesAudioMap;
  }

  set relatedWordIDs(List<String> relatedWordIDs) =>
      _relatedWordIDs = relatedWordIDs;

  set examplesAudio(Map<String, List<StorageFile>> examplesAudio_) {
    if (examples.isEmpty) {
      throw NotSetupException('Examples must be set before examplesAudio');
    }
    examples.keys.forEach((key) {
      if (examplesAudio_.containsKey(key)) {
        _examplesAudio.addAll(examplesAudio_[key]);
      }
      _examplesAudio.add(null);
    });
    // Remove the last null we add
    _examplesAudio.removeLast();
  }

  set examples(Map<String, List<String>> examples_) {
    _examples = examples_.map((key, value) => MapEntry(key, value.join('#')));
  }

  List<WordTag> get tags => EnumToString.fromList(WordTag.values, _tags);

  set tags(List<WordTag> tags_) => _tags = EnumToString.toList(tags_);

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
