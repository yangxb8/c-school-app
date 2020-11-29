import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';
import 'package:flutter/foundation.dart';

part 'word_meaning.flamingo.dart';

class WordMeaning extends Model {
  WordMeaning({
    @required this.meaning,
    @required Map<String, StorageFile> examples,
    Map<String, dynamic> values,
  })  : _examples = examples.keys.toList(),
        _exampleAudios = examples.values.toList(),
        super(values: values);

  @Field()
  String meaning;

  @Field()
  // ignore: prefer_final_fields
  List<String> _examples;

  /// Example ordinal : audio file
  @StorageField()
  // ignore: prefer_final_fields
  List<StorageFile> _exampleAudios;

  Map<String, StorageFile> get exampleAndAudios {
    var exampleAndAudios_ = <String, StorageFile>{};
    for (var i = 0; i < _examples.length; i++) {
      exampleAndAudios_[_examples[i]] = _exampleAudios[i];
    }
    return exampleAndAudios_;
  }

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
