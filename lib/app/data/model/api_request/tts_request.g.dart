// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsRequest _$TtsRequestFromJson(Map<String, dynamic> json) {
  return TtsRequest(
    Text: json['Text'] as String,
    SessionId: json['SessionId'] as String,
    ModelType: json['ModelType'] as int,
    VoiceType: json['VoiceType'] as int,
    Codec: json['Codec'] as String,
  );
}

Map<String, dynamic> _$TtsRequestToJson(TtsRequest instance) =>
    <String, dynamic>{
      'Codec': instance.Codec,
      'ModelType': instance.ModelType,
      'SessionId': instance.SessionId,
      'Text': instance.Text,
      'VoiceType': instance.VoiceType,
    };
