import 'package:json_annotation/json_annotation.dart';

part 'speech_evaluation_result.g.dart';

/// This class will be persisted into cloud storage once created. It's NOT
/// be intended to retrieved from cloud storage in App. Instead, the data
/// might be directly extracted from cloud storage for analysis in the future.
@JsonSerializable()
class SpeechEvaluationResult {
  final String userId;
  final String examId;
  final String speechDataPath;
  final SentenceInfo sentenceInfo;

  SpeechEvaluationResult(
      {this.userId, this.examId, this.speechDataPath, this.sentenceInfo});
  factory SpeechEvaluationResult.fromJson(Map<String, dynamic> json) =>
      _$SpeechEvaluationResultFromJson(json);
  Map<String, dynamic> toJson() => _$SpeechEvaluationResultToJson(this);
}

@JsonSerializable()
class SentenceInfo {
  @JsonKey(name: 'SuggestedScore')
  final double suggestedScore;
  @JsonKey(name: 'PronAccuracy')
  final double pronAccuracy;
  @JsonKey(name: 'PronFluency')
  final double pronFluency;
  @JsonKey(name: 'PronCompletion')
  final double pronCompletion;
  @JsonKey(name: 'Words')
  final List<WordInfo> words;
  @JsonKey(name: 'SessionId')
  final String sessionId;

  SentenceInfo(
      {this.suggestedScore,
      this.pronAccuracy,
      this.pronFluency,
      this.pronCompletion,
      this.words,
      this.sessionId});
  factory SentenceInfo.fromJson(Map<String, dynamic> json) =>
      _$SentenceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SentenceInfoToJson(this);
}

@JsonSerializable()
class WordInfo {
  @JsonKey(name: 'PronAccuracy')
  final double pronAccuracy;
  @JsonKey(name: 'PronFluency')
  final double pronFluency;
  @JsonKey(name: 'Word')
  final String word;
  @JsonKey(
      name: 'MatchTag',
      fromJson: MatchResultUtil.fromInt,
      toJson: MatchResultUtil.toInt)
  final MatchResult matchResult;
  @JsonKey(name: 'PhoneInfos')
  final List<PhoneInfo> phoneInfos;

  WordInfo(
      {this.pronAccuracy,
      this.pronFluency,
      this.word,
      this.matchResult,
      this.phoneInfos});
  factory WordInfo.fromJson(Map<String, dynamic> json) =>
      _$WordInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WordInfoToJson(this);
}

@JsonSerializable()
class PhoneInfo {
  @JsonKey(name: 'PronAccuracy')
  final double pronAccuracy;
  @JsonKey(name: 'DetectedStress')
  final bool detectedStress;
  @JsonKey(name: 'Stress')
  final bool refStress;
  @JsonKey(name: 'Phone')
  final String detectedPhone;
  @JsonKey(name: 'ReferencePhone')
  final String refPhone;
  @JsonKey(
      name: 'MatchTag',
      fromJson: MatchResultUtil.fromInt,
      toJson: MatchResultUtil.toInt)
  final MatchResult matchResult;

  PhoneInfo(
      {this.pronAccuracy,
      this.detectedStress,
      this.refStress,
      this.detectedPhone,
      this.refPhone,
      this.matchResult});
  factory PhoneInfo.fromJson(Map<String, dynamic> json) =>
      _$PhoneInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneInfoToJson(this);
}

enum MatchResult { MATCH, ADDED, LACKED, WRONG, UNDETECTED }

extension MatchResultUtil on MatchResult {
  static MatchResult fromInt(int matchResultInt) {
    return matchResultInt == null ? null : MatchResult.values[matchResultInt];
  }

  static int toInt(MatchResult matchResult) {
    if (matchResult == null) return null;
    for (var i = 0; i < MatchResult.values.length; i++) {
      if (MatchResult.values[i] == matchResult) {
        return i;
      }
    }
    // impossible
    return 0;
  }
}
