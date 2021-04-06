import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'speech_audio.flamingo.dart';

class SpeechAudio extends Model{
  SpeechAudio({
    this.audio,
    this.timeSeries,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @StorageField()
  StorageFile? audio;

  /// Start times of each hanzi
  @Field()
  List<int>? timeSeries;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}