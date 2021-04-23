// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'tts_request.g.dart';

@JsonSerializable()
class TtsRequest {
  TtsRequest(
      {required this.Text,
      required this.SessionId,
      this.ModelType = 1,
      this.VoiceType = 101009,
      this.Codec = 'mp3'});

  factory TtsRequest.fromJson(Map<String, dynamic> json) =>
      _$TtsRequestFromJson(json);

  final String Codec;
  final int ModelType;
  final String SessionId;

  /// 合成语音的源文本，按UTF-8编码统一计算。 中文最大支持110个汉字（全角标点符号算一个汉字）
  final String Text;

  /// 101009-智芸，知性女声
  final int VoiceType;

  /// String representation of this json object
  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => _$TtsRequestToJson(this);
}
