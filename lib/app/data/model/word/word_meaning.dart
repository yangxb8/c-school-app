// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import 'word_example.dart';

part 'word_meaning.flamingo.dart';

const PINYIN_SEPARATOR = '-';

class WordMeaning extends Model {
  WordMeaning({
    this.meaning,
    List<WordExample>? examples,
    List<String>? exampleHanzis,
    List<String>? exampleMeanings,
    List<String>? examplePinyins,
    Map<String, dynamic>? values,
  })  : examples = examples ??
            _generateWordExample(
                exampleHanzis, exampleMeanings, examplePinyins),
        super(values: values);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @Field()
  String? meaning;

  @ModelField()
  List<WordExample>? examples;

  static List<WordExample> _generateWordExample(
    List<String>? exampleHanzis,
    List<String>? exampleMeanings,
    List<String>? examplePinyins,
  ) =>
      exampleHanzis == null
          ? const []
          : List.generate(
              exampleHanzis.length,
              (i) => WordExample(
                    example: exampleHanzis.elementAtOrElse(i, () => ''),
                    meaning: exampleMeanings!.elementAtOrElse(i, () => ''),
                    pinyin: examplePinyins!
                        .elementAtOrElse(i, () => '')
                        .split(PINYIN_SEPARATOR),
                  ));
}
