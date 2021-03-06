// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/lecture.dart';
import 'package:c_school_app/app/model/searchable.dart';
import 'package:c_school_app/app/model/word_meaning.dart';
import 'package:c_school_app/service/lecture_service.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> implements Searchable{
  static LectureService lectureService = Get.find<LectureService>();

  Word({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  })  : wordId = id,
        tags =
            id == null ? [] : [id.split('-').first], // Assign lectureId to tags
        super(id: id, snapshot: snapshot, values: values);

  @Field()
  String wordId;

  /// Example: [['我'],[们]]
  @Field()
  List<String> word = [];

  /// Example: [['wo'],['men']]
  @Field()
  List<String> pinyin = [];

  /// Usage and other information about this word
  @Field()
  String explanation = '';

  @Field()
  String partOfSentence = '';

  @Field()
  String hint = '';

  /// 日语意思
  @ModelField()
  List<WordMeaning> wordMeanings = [];

  /// related word in examples
  @Field()
  List<String> _relatedWordIds = [];

  /// Same word but with different meanings
  @Field()
  List<String> _otherMeaningIds = [];

  /// 拆字
  @Field()
  List<String> breakdowns = [];

  /// Converted from WordTag enum
  @Field()
  List<String> tags = [];

  /// Hash of word pic for display by blurhash
  @Field()
  String picHash = '';

  /// If the word has pic in cloud storage
  @StorageField()
  StorageFile pic;

  /// If the word has wordAudio in cloud storage
  @StorageField()
  StorageFile wordAudioMale;

  @StorageField()
  StorageFile wordAudioFemale;

  List<Word> get relatedWords {
    if (_relatedWordIds.isBlank) {
      return [];
    } else {
      return lectureService.findWordsByIds(_relatedWordIds);
    }
  }

  set relatedWordIDs(List<String> relatedWordIDs) =>
      _relatedWordIds = relatedWordIDs;

  List<Word> get otherMeanings {
    if (_otherMeaningIds.isBlank) {
      return [];
    } else {
      return lectureService.findWordsByIds(_otherMeaningIds);
    }
  }

  set otherMeaningIds(List<String> otherMeaningIds) =>
      _otherMeaningIds = otherMeaningIds;

  Lecture get lecture => lectureService.findLectureById(lectureId);

  String get lectureId => id.split('-').first;

  int get viewedCount => lectureService.wordViewedCount(this);

  bool get isLiked => lectureService.isWordLiked(this);

  String get wordAsString => word.join();

  WordMemoryStatus get statue => lectureService.getMemoryStatusOfWord(this);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> get searchableProperties => {
    'wordAsString': wordAsString,
    'pinyin':pinyin,
    'wordMeanings': wordMeanings.map((m) => m.meaning),
    'tags':tags
  };
}

enum WordMemoryStatus { REMEMBERED, NORMAL, FORGOT, NOT_REVIEWED }
