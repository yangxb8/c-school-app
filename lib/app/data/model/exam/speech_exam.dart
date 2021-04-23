// 📦 Package imports:

// 📦 Package imports:
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

// 🌎 Project imports:
import '../speech_audio.dart';
import 'exam_base.dart';

part 'speech_exam.flamingo.dart';

class SpeechExam extends Exam<SpeechExam> {
  SpeechExam({
    String? id,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
  }) : super(id: id, snapshot: snapshot, values: values);

  /// Text version of refAudio
  @Field()
  String? refText = '';

  @Field()
  List<String>? refPinyins = [];

  @override
  void fromData(Map<String, dynamic> data) {
    super.fromData(data);
    _$fromData(this, data);
  }

  @override
  Map<String, dynamic> toData() {
    var map = <String, dynamic>{};
    map.addAll(super.toData());
    map.addAll(_$toData(this));
    return map;
  }

  /// Audio data for the original speech
  @ModelField()
  SpeechAudio? refSpeech;

  /// Speech Evaluation mode
  @Field()
  String? _mode;

  SpeechExamMode? get mode => _mode == null
      ? null
      : EnumToString.fromString(SpeechExamMode.values, _mode!);

  set mode(SpeechExamMode? mode) => _mode = EnumToString.convertToString(mode);
}

enum SpeechExamMode { WORD, SENTENCE, PARAGRAPH, FREE }
