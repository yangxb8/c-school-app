import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:spoken_chinese/app/models/word_meaning.dart';
import 'package:supercharged/supercharged.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/app/models/class.dart';
import 'package:spoken_chinese/service/class_service.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> {
  static ClassService classService = Get.find<ClassService>();

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
  @ModelField()
  List<WordMeaning> wordMeanings;

  /// related word in examples
  @Field()
  List<String> _relatedWordIDs;

  /// 拆字
  @Field()
  List<String> breakdowns;

  /// Converted from WordTag enum
  @Field()
  List<String> _tags;

  /// If the word has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// If the word has wordAudio in cloud storage
  @StorageField()
  StorageFile wordAudio;

  List<Word> get relatedWords => classService.findWordsByIds(_relatedWordIDs);

  set relatedWordIDs(List<String> relatedWordIDs) =>
      _relatedWordIDs = relatedWordIDs;

  List<WordTag> get tags => EnumToString.fromList(WordTag.values, _tags);

  set tags(List<WordTag> tags_) => _tags = EnumToString.toList(tags_);

  CSchoolClass get cschoolClass =>
      classService.findClassesById(id.split('-').first).single;

  int get viewedCount => classService.wordViewedCount(this);

  bool get isLiked => classService.isWordLiked(this);

  String get wordAsString => word.join();

  WordStatus get statue => classService.getStausOfWord(this);

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

enum WordStatus { REMEMBERED, NORMAL, FORGOT }
