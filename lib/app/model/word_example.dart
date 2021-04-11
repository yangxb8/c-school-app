// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/speech_audio.dart';

part 'word_example.flamingo.dart';

/// Represent a single example of word
class WordExample extends Model {
  WordExample({
    this.example,
    this.meaning,
    this.pinyin,
    this.audioMale,
    this.audioFemale,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @Field()
  String? example;

  @Field()
  String? meaning;

  @Field()
  List<String>? pinyin;

  @ModelField()
  SpeechAudio? audioMale;

  @ModelField()
  SpeechAudio? audioFemale;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
