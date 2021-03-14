import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'tts_request.g.dart';

@JsonSerializable()
class TtsRequest{
  /// 合成语音的源文本，按UTF-8编码统一计算。 中文最大支持110个汉字（全角标点符号算一个汉字）
  final String Text;
  final String SessionId;
  final int ModeType = 1;
  /// 101009-智芸，知性女声
  final int VoiceType = 101009;
  final String Codec = 'mp3';

  TtsRequest({required this.Text, required this.SessionId});
  factory TtsRequest.fromJson(Map<String, dynamic> json) => _$SoeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SoeRequestToJson(this);

  /// String representation of this json object
  @override
  String toString() => jsonEncode(toJson());
}