// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_evaluation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeechEvaluationResult _$SpeechEvaluationResultFromJson(
    Map<String, dynamic> json) {
  return SpeechEvaluationResult(
    (json['SuggestedScore'] as num)?.toDouble(),
    (json['PronAccuracy'] as num)?.toDouble(),
    (json['PronFluency'] as num)?.toDouble(),
    (json['PronCompletion'] as num)?.toDouble(),
    (json['Words'] as List)
        ?.map((e) =>
            e == null ? null : WordInfo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['SessionId'] as String,
  );
}

Map<String, dynamic> _$SpeechEvaluationResultToJson(
        SpeechEvaluationResult instance) =>
    <String, dynamic>{
      'SuggestedScore': instance.SuggestedScore,
      'PronAccuracy': instance.PronAccuracy,
      'PronFluency': instance.PronFluency,
      'PronCompletion': instance.PronCompletion,
      'Words': instance.Words,
      'SessionId': instance.SessionId,
    };

WordInfo _$WordInfoFromJson(Map<String, dynamic> json) {
  return WordInfo(
    (json['PronAccuracy'] as num)?.toDouble(),
    (json['PronFluency'] as num)?.toDouble(),
    json['Word'] as String,
    MatchResultUtil.fromInt(json['MatchTag'] as int),
    (json['PhoneInfos'] as List)
        ?.map((e) =>
            e == null ? null : PhoneInfo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$WordInfoToJson(WordInfo instance) => <String, dynamic>{
      'PronAccuracy': instance.pronAccuracy,
      'PronFluency': instance.pronFluency,
      'Word': instance.word,
      'MatchTag': MatchResultUtil.toInt(instance.matchResult),
      'PhoneInfos': instance.phoneInfos,
    };

PhoneInfo _$PhoneInfoFromJson(Map<String, dynamic> json) {
  return PhoneInfo(
    (json['PronAccuracy'] as num)?.toDouble(),
    json['DetectedStress'] as bool,
    json['Stress'] as bool,
    json['Phone'] as String,
    json['ReferencePhone'] as String,
    MatchResultUtil.fromInt(json['MatchTag'] as int),
  );
}

Map<String, dynamic> _$PhoneInfoToJson(PhoneInfo instance) => <String, dynamic>{
      'PronAccuracy': instance.pronAccuracy,
      'DetectedStress': instance.detectedStress,
      'Stress': instance.refStress,
      'Phone': instance.detectedPhone,
      'ReferencePhone': instance.refPhone,
      'MatchTag': MatchResultUtil.toInt(instance.matchResult),
    };
