import 'package:c_school_app/app/models/class_entity_interface.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:c_school_app/app/models/word_meaning.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/models/class.dart';
import 'package:c_school_app/service/class_service.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> implements ClassEntityInterface{
  static ClassService classService = Get.find<ClassService>();

  Word({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : wordId = id,
        tags = id.isNull? []:[id.split('-').first], // Assign classId to tags
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String wordId;

  /// Example: [['我'],[们]]
  @Field()
  List<String> word;

  /// Example: [['wo'],['men']]
  @Field()
  List<String> pinyin;

  /// Usage and other information about this word
  @Field()
  String detail;

  @Field()
  String partOfSentence;

  @Field()
  String hint;

  /// 日语意思
  @ModelField()
  List<WordMeaning> wordMeanings;

  /// related word in examples
  @Field()
  List<String> _relatedWordIds;
  
  /// Same word but with different meanings
  @Field()
  List<String> _otherMeaningIds;

  /// 拆字
  @Field()
  List<String> breakdowns;

  /// Converted from WordTag enum
  @Field()
  List<String> tags;

  /// Hash of word pic for display by blurhash
  @Field()
  String picHash;

  /// If the word has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// If the word has wordAudio in cloud storage
  @StorageField()
  StorageFile wordAudioMale;

  @StorageField()
  StorageFile wordAudioFemale;

  List<Word> get relatedWords {
    if (_relatedWordIds.isNullOrBlank) {
      return [];
    } else {
      return classService.findWordsByIds(_relatedWordIds);
    }
  }

  set relatedWordIDs(List<String> relatedWordIDs) =>
      _relatedWordIds = relatedWordIDs;  
  
  List<Word> get otherMeanings {
    if (_otherMeaningIds.isNullOrBlank) {
      return [];
    } else {
      return classService.findWordsByIds(_otherMeaningIds);
    }
  }

  set otherMeaningIds(List<String> otherMeaningIds) =>
      _otherMeaningIds = otherMeaningIds;

  CSchoolClass get cschoolClass =>
      classService.findClassesById(id.split('-').first).single;

  String get cschoolClassId => id.split('-').first;

  int get viewedCount => classService.wordViewedCount(this);

  bool get isLiked => classService.isWordLiked(this);

  String get wordAsString => word.join();

  WordMemoryStatus get statue => classService.getMemoryStatusOfWord(this);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}

enum WordMemoryStatus { REMEMBERED, NORMAL, FORGOT, NOT_REVIEWED }
