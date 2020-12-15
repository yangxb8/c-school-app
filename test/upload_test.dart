import 'package:c_school_app/app/models/word.dart';
import 'package:c_school_app/app/models/word_meaning.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

final COLUMN_WORD_ID = 1;
final COLUMN_MEANING = 3;
final COLUMN_WORD = 4;
final COLUMN_PINYIN = 5;
final COLUMN_HINT = 6;
final COLUMN_EXAMPLE = 9;
final COLUMN_EXAMPLE_MEANING = 10;
final COLUMN_EXAMPLE_PINYIN = 11;
final COLUMN_RELATED_WORD_ID = 12;
final COLUMN_OTHER_MEANING_ID = 13;
final COLUMN_PART_OF_SENTENCE = 14;
final SEPARATOR = '/';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  var csv = CsvToListConverter()
      .convert(await rootBundle.loadString('assets/upload/words.csv'));
  var words = csv.map((row) => Word(id: row[COLUMN_WORD_ID])
    ..word = row[COLUMN_WORD]
    ..pinyin = row[COLUMN_PINYIN].split(SEPARATOR)
    ..partOfSentence = row[COLUMN_PART_OF_SENTENCE]
    ..wordMeanings = [
      WordMeaning(
          meaning: row[COLUMN_MEANING].replace(SEPARATOR, ','),
          examples: row[COLUMN_EXAMPLE].split(SEPARATOR),
          exampleMeanings: row[COLUMN_EXAMPLE_MEANING].split(SEPARATOR),
          examplePinyins: row[COLUMN_EXAMPLE_PINYIN].split(SEPARATOR))
    ]
    ..hint = row[COLUMN_HINT]
    ..relatedWordIDs = row[COLUMN_RELATED_WORD_ID].split(SEPARATOR)
    ..otherMeaningIds = row[COLUMN_OTHER_MEANING_ID].split(SEPARATOR)).toList();
  words.forEach((word)=>print(word.wordMeanings[0].meaning));
}
