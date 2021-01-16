// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_evaluation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeechEvaluationResult _$SpeechEvaluationResultFromJson(
    Map<String, dynamic> json) {
  return SpeechEvaluationResult(
    userId: json['userId'] as String,
    examId: json['examId'] as String,
    speechDataPath: json['speechDataPath'] as String,
    sentenceInfo: json['sentenceInfo'] == null
        ? null
        : SentenceInfo.fromJson(json['sentenceInfo'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SpeechEvaluationResultToJson(
        SpeechEvaluationResult instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'examId': instance.examId,
      'speechDataPath': instance.speechDataPath,
      'sentenceInfo': instance.sentenceInfo,
    };

SentenceInfo _$SentenceInfoFromJson(Map<String, dynamic> json) {
  return SentenceInfo(
    suggestedScore: (json['SuggestedScore'] as num)?.toDouble(),
    pronAccuracy: (json['PronAccuracy'] as num)?.toDouble(),
    pronFluency: (json['PronFluency'] as num)?.toDouble(),
    pronCompletion: (json['PronCompletion'] as num)?.toDouble(),
    words: (json['Words'] as List)
        ?.map((e) =>
            e == null ? null : WordInfo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    sessionId: json['SessionId'] as String,
  );
}

Map<String, dynamic> _$SentenceInfoToJson(SentenceInfo instance) =>
    <String, dynamic>{
      'SuggestedScore': instance.suggestedScore,
      'PronAccuracy': instance.pronAccuracy,
      'PronFluency': instance.pronFluency,
      'PronCompletion': instance.pronCompletion,
      'Words': instance.words,
      'SessionId': instance.sessionId,
    };

WordInfo _$WordInfoFromJson(Map<String, dynamic> json) {
  return WordInfo(
    pronAccuracy: (json['PronAccuracy'] as num)?.toDouble(),
    pronFluency: (json['PronFluency'] as num)?.toDouble(),
    word: json['Word'] as String,
    matchResult: MatchResultUtil.fromInt(json['MatchTag'] as int),
    phoneInfos: (json['PhoneInfos'] as List)
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
    pronAccuracy: (json['PronAccuracy'] as num)?.toDouble(),
    detectedStress: json['DetectedStress'] as bool,
    refStress: json['Stress'] as bool,
    detectedPhone: json['Phone'] as String,
    refPhone: json['ReferencePhone'] as String,
    matchResult: MatchResultUtil.fromInt(json['MatchTag'] as int),
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
