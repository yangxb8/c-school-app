// 📦 Package imports:
import 'package:c_school_app/app/model/speech_audio.dart';

/// Represent a single example of word
class WordExample {
  final String example;
  final String meaning;
  final List<String> pinyin;
  final SpeechAudio audioMale;
  final SpeechAudio audioFemale;

  WordExample(
      {required this.example,
        required this.meaning,
        required this.pinyin,
        required this.audioMale,
        required this.audioFemale,
      });
}
