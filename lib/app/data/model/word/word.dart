// 📦 Package imports:

// 🌎 Project imports:
import 'package:c_school_app/app/data/interface/filterable.dart';
import 'package:c_school_app/app/data/repository/lecture_repository.dart';
import 'package:c_school_app/app/data/repository/word_repository.dart';
// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:get/get.dart';

import '../../interface/searchable.dart';
import '../../../core/service/lecture_service.dart';
import '../lecture.dart';
import '../speech_audio.dart';
import 'word_meaning.dart';

part 'word.flamingo.dart';

/// id is used as primary key for any word
class Word extends Document<Word> with Filterable implements Searchable {
  Word({
    String? id,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
  })  : wordId = id,
        tags =
            id == null ? [] : [id.split('-').first], // Assign lectureId to tags
        super(id: id, snapshot: snapshot, values: values);

  /// Example: [['我'],[们]]
  @Field()
  List<String>? word = [];

  /// Example: [['wo'],['men']]
  @Field()
  List<String>? pinyin = [];

  /// Usage and other information about this word
  @Field()
  String? explanation = '';

  @Field()
  String? partOfSentence = '';

  @Field()
  String? hint = '';

  /// related word in examples
  @Field()
  List<String>? _relatedWordIds = [];

  /// Same word but with different meanings
  @Field()
  List<String>? _otherMeaningIds = [];

  /// 拆字
  @Field()
  List<String>? breakdowns = [];

  /// Converted from WordTag enum
  @Field()
  List<String>? tags = [];

  /// Hash of word pic for display by blurhash
  @Field()
  String? picHash = '';

  /// 日语意思
  @ModelField()
  List<WordMeaning>? wordMeanings = [];

  @override
  Map<String, dynamic> get searchableProperties => {
        'wordAsString': wordAsString,
        'pinyin': pinyin,
        'wordMeanings': wordMeanings!.map((m) => m.meaning),
        'tags': tags
      };

  @override
  Map<String, dynamic> get filterableProperties =>
      {'wordId': wordId, 'tags': tags, 'wordMemoryStatus': status};

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @Field()
  String? wordId;

  /// If the word has pic in cloud storage
  @StorageField()
  StorageFile? pic;

  /// If the word has wordAudio in cloud storage
  @ModelField()
  SpeechAudio? wordAudioMale;

  @ModelField()
  SpeechAudio? wordAudioFemale;

  String get lectureId => id.split('-').first;

  String get wordAsString => word!.join();
}

enum WordMemoryStatus { REMEMBERED, NORMAL, FORGOT, NOT_REVIEWED }

extension WordUtil on Word {
  List<Word> get relatedWords {
    if (_relatedWordIds.isBlank!) {
      return [];
    } else {
      return Get.find<WordRepository>().findWordBy({'wordId': _relatedWordIds});
    }
  }

  set relatedWordIDs(List<String> relatedWordIDs) =>
      _relatedWordIds = relatedWordIDs;

  List<Word> get otherMeanings {
    if (_otherMeaningIds.isBlank!) {
      return [];
    } else {
      return Get.find<WordRepository>()
          .findWordBy({'wordId': _otherMeaningIds});
    }
  }

  set otherMeaningIds(List<String> otherMeaningIds) =>
      _otherMeaningIds = otherMeaningIds;

  Lecture get lecture => Get.find<LectureRepository>()
      .findLectureBy({'lectureId': lectureId}).single;

  int get viewedCount => Get.find<LectureService>().wordViewedCount(this);

  bool get isLiked => Get.find<LectureService>().isWordLiked(this);

  WordMemoryStatus get status =>
      Get.find<LectureService>().getMemoryStatusOfWord(this);
}
