import 'package:json_annotation/json_annotation.dart';

part 'speech_evaluation_result.g.dart';

@JsonSerializable()
class SpeechEvaluationResult {
  final double SuggestedScore;
  final double PronAccuracy;
  final double PronFluency;
  final double PronCompletion;
  final List<WordInfo> Words;
  final String SessionId;

  SpeechEvaluationResult(this.SuggestedScore, this.PronAccuracy,
      this.PronFluency, this.PronCompletion, this.Words, this.SessionId);
  factory SpeechEvaluationResult.fromJson(Map<String, dynamic> json) =>
      _$SpeechEvaluationResultFromJson(json);
  Map<String, dynamic> toJson() => _$SpeechEvaluationResultToJson(this);
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

  WordInfo(this.pronAccuracy, this.pronFluency, this.word, this.matchResult,
      this.phoneInfos);
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

  PhoneInfo(this.pronAccuracy, this.detectedStress, this.refStress,
      this.detectedPhone, this.refPhone, this.matchResult);
  factory PhoneInfo.fromJson(Map<String, dynamic> json) =>
      _$PhoneInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneInfoToJson(this);
}

enum MatchResult { MATCH, ADDED, LACKED, WRONG, UNDETECTED }

extension MatchResultUtil on MatchResult {
  static MatchResult fromInt(int matchResultInt) {
    return matchResultInt==null? null:MatchResult.values[matchResultInt];
  }

  static int toInt(MatchResult matchResult) {
    if(matchResult==null) return null;
    for (var i = 0; i < MatchResult.values.length; i++) {
      if (MatchResult.values[i] == matchResult) {
        return i;
      }
    }
    // impossible
    return 0;
  }
}
