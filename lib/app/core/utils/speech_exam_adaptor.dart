// 🌎 Project imports:

// 🌎 Project imports:

// 🌎 Project imports:
import '../../data/model/exam/speech_exam.dart';
import '../../data/model/word/word.dart';
import '../../data/model/word/word_example.dart';

class SpeechExamAdaptor {
  static SpeechExam wordToExam(Word word) => SpeechExam()
    ..mode = SpeechExamMode.SENTENCE
    ..refSpeech = word.wordAudioFemale
    ..refText = word.wordAsString
    ..refPinyins = word.pinyin;

  static SpeechExam WordExampleToExam(WordExample wordExample) => SpeechExam()
    ..mode = SpeechExamMode.SENTENCE
    ..refSpeech = wordExample.audioFemale
    ..refText = wordExample.example
    ..refPinyins = wordExample.pinyin;
}
