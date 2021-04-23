// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'speech_audio.flamingo.dart';

class SpeechAudio extends Model {
  SpeechAudio({
    this.audio,
    this.timeSeries,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @StorageField()
  StorageFile? audio;

  /// Start times of each hanzi
  @Field()
  List<int>? timeSeries;
}
