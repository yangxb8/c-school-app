import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flutter/foundation.dart';

import 'word_example.dart';

part 'word_meaning.flamingo.dart';

class WordMeaning extends Model {
  WordMeaning({
    @required this.meaning,
    @required List<String> examples,
    @required List<String> exampleMeanings,
    @required List<String> examplePinyins,
    Map<String, dynamic> values,
  })  : _examples = examples,
        _exampleMeanings = exampleMeanings,
        _examplePinyins = examplePinyins,
        super(values: values);

  @Field()
  String meaning;

  @Field()
  // ignore: prefer_final_fields
  List<String> _examples;

  @Field()
  // ignore: prefer_final_fields
  List<String> _exampleMeanings;

  @Field()
  // ignore: prefer_final_fields
  List<String> _examplePinyins;

  /// Example ordinal : audio file
  @StorageField()
  // ignore: prefer_final_fields
  List<StorageFile> exampleMaleAudios;

  /// Example ordinal : audio file
  @StorageField()
  // ignore: prefer_final_fields
  List<StorageFile> exampleFemaleAudios;

  List<WordExample> get examples {
    var examples = [];
    for (var i = 0; i < _examples.length; i++) {
      examples.add(WordExample(
          example: _examples[i],
          meaning: _exampleMeanings[i],
          pinyin: _examplePinyins[i],
          audioMale: exampleMaleAudios[i],
          audioFemale: exampleFemaleAudios[i]
      ));
    }
    return examples;
  }


  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
