import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/app/model/word.dart';
import 'package:c_school_app/app/model/word_example.dart';

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
