// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoeRequest _$SoeRequestFromJson(Map<String, dynamic> json) {
  return SoeRequest(
    SeqId: json['SeqId'],
    IsEnd: json['IsEnd'],
    VoiceFileType: json['VoiceFileType'],
    VoiceEncodeType: json['VoiceEncodeType'],
    UserVoiceData: json['UserVoiceData'] as String,
    SessionId: json['SessionId'] as String,
    RefText: json['RefText'] as String?,
    WorkMode: json['WorkMode'],
    EvalMode: json['EvalMode'] as int,
    ScoreCoeff: (json['ScoreCoeff'] as num).toDouble(),
    StorageMode: json['StorageMode'],
    SentenceInfoEnabled: json['SentenceInfoEnabled'],
    ServerType: json['ServerType'],
    IsAsync: json['IsAsync'],
  );
}

Map<String, dynamic> _$SoeRequestToJson(SoeRequest instance) =>
    <String, dynamic>{
      'EvalMode': instance.EvalMode,
      'IsAsync': instance.IsAsync,
      'IsEnd': instance.IsEnd,
      'RefText': instance.RefText,
      'ScoreCoeff': instance.ScoreCoeff,
      'SentenceInfoEnabled': instance.SentenceInfoEnabled,
      'SeqId': instance.SeqId,
      'ServerType': instance.ServerType,
      'SessionId': instance.SessionId,
      'StorageMode': instance.StorageMode,
      'UserVoiceData': instance.UserVoiceData,
      'VoiceEncodeType': instance.VoiceEncodeType,
      'VoiceFileType': instance.VoiceFileType,
      'WorkMode': instance.WorkMode,
    };
