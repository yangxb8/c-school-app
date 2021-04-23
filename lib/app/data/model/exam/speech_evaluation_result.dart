// 📦 Package imports:
import 'package:enum_to_string/enum_to_string.dart';
import 'package:json_annotation/json_annotation.dart';

// 🌎 Project imports:
import '../../../core/utils/index.dart';

part 'speech_evaluation_result.g.dart';

/// This class will be persisted into cloud storage once created. It's NOT
/// be intended to retrieved from cloud storage in App. Instead, the data
/// might be directly extracted from cloud storage for analysis in the future.
@JsonSerializable()
class SpeechEvaluationResult {
  SpeechEvaluationResult(
      {this.userId, this.examId, this.speechDataPath, this.sentenceInfo});

  factory SpeechEvaluationResult.fromJson(Map<String, dynamic> json) =>
      _$SpeechEvaluationResultFromJson(json);

  final String? examId;
  final SentenceInfo? sentenceInfo;
  final String? speechDataPath;
  final String? userId;

  Map<String, dynamic> toJson() => _$SpeechEvaluationResultToJson(this);
}

@JsonSerializable()
class SentenceInfo {
  SentenceInfo(
      {this.suggestedScore,
      this.pronAccuracy,
      this.pronFluency,
      this.pronCompletion,
      this.words});

  factory SentenceInfo.fromJson(Map<String, dynamic> json) =>
      _$SentenceInfoFromJson(json);

  @JsonKey(name: 'SuggestedScore')
  final double? suggestedScore;

  @JsonKey(name: 'PronAccuracy')
  final double? pronAccuracy;

  @JsonKey(name: 'PronFluency')
  final double? pronFluency;

  @JsonKey(name: 'PronCompletion')
  final double? pronCompletion;

  @JsonKey(name: 'Words')
  final List<WordInfo>? words;

  double get displaySuggestedScore => suggestedScore ?? -1.0;

  double get displayPronAccuracy => pronAccuracy ?? -1.0;

  double get displayPronFluency =>
      pronFluency == null ? -1.0 : pronFluency! * 100;

  double get displayPronCompletion =>
      pronCompletion == null ? -1.0 : pronCompletion! * 100;

  Map<String, dynamic> toJson() => _$SentenceInfoToJson(this);
}

@JsonSerializable()
class WordInfo {
  WordInfo(
      {this.beginTime,
      this.endTime,
      this.referenceWord,
      this.pronAccuracy,
      this.pronFluency,
      this.word,
      this.matchTag,
      this.phoneInfos});

  factory WordInfo.fromJson(Map<String, dynamic> json) =>
      _$WordInfoFromJson(json);

  @JsonKey(name: 'MemBeginTime')
  final int? beginTime;

  @JsonKey(name: 'MemEndTime')
  final int? endTime;

  @JsonKey(name: 'PronAccuracy')
  final double? pronAccuracy;

  @JsonKey(name: 'PronFluency')
  final double? pronFluency;

  @JsonKey(name: 'Word')
  final String? word;

  @JsonKey(
      name: 'MatchTag',
      fromJson: MatchResultUtil.fromInt,
      toJson: EnumToString.convertToString)
  final MatchResult? matchTag;

  @JsonKey(name: 'PhoneInfos')
  final List<PhoneInfo>? phoneInfos;

  @JsonKey(name: 'ReferenceWord')
  final String? referenceWord;

  double get displayPronAccuracy => pronAccuracy ?? -1.0;

  double get displayPronFluency =>
      pronFluency == null ? -1.0 : pronFluency! * 100;

  double get displaySuggestedScore {
    if (pronFluency == null || pronFluency == null) {
      return -1.0;
    } else {
      return pronFluency! * pronAccuracy!;
    }
  }

  Map<String, dynamic> toJson() => _$WordInfoToJson(this);
}

@JsonSerializable()
class PhoneInfo {
  PhoneInfo(
      {this.beginTime,
      this.endTime,
      this.referenceStress,
      this.referencePhone,
      this.pronAccuracy,
      this.detectedStress,
      this.detectedPhone,
      this.matchTag});

  factory PhoneInfo.fromJson(Map<String, dynamic> json) =>
      _$PhoneInfoFromJson(json);

  @JsonKey(name: 'MemBeginTime')
  final int? beginTime;

  @JsonKey(name: 'MemEndTime')
  final int? endTime;

  @JsonKey(name: 'PronAccuracy')
  final double? pronAccuracy;

  @JsonKey(name: 'DetectedStress')
  final bool? detectedStress;

  @JsonKey(name: 'Stress')
  final bool? referenceStress;

  @JsonKey(name: 'Phone')
  final String? detectedPhone;

  @JsonKey(name: 'ReferencePhone')
  final String? referencePhone;

  @JsonKey(
      name: 'MatchTag',
      fromJson: MatchResultUtil.fromInt,
      toJson: EnumToString.convertToString)
  final MatchResult? matchTag;

  double get displayPronAccuracy => pronAccuracy ?? -1.0;

  Map<String, dynamic> toJson() => _$PhoneInfoToJson(this);
}

enum MatchResult { match, added, lacked, wrong, undetected }

extension MatchResultUtil on MatchResult {
  static MatchResult? fromInt(int? matchResultInt) {
    return matchResultInt == null ? null : MatchResult.values[matchResultInt];
  }
}

extension PinyinExtension on WordInfo {
  String get pinyin => PinyinUtil.transformPinyin(
          [phoneInfos!.map((p) => p.referencePhone ?? p.detectedPhone!).join()])
      .single;
}
