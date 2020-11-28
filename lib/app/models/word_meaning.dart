import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'word_meaning.flamingo.dart';

class WordMeaning extends Model {
  WordMeaning({
    this.meaning,
    Map<String, StorageFile> examples,
    Map<String, dynamic> values,
  })  : _examples = examples.keys,
        _exampleAudios = examples.values,
        super(values: values);

  @Field()
  String meaning;

  @Field()
  List<String> _examples;

  /// Example ordinal : audio file
  @StorageField()
  List<StorageFile> _exampleAudios;

  Map<String, StorageFile> get exampleAndAudios {
    var exampleAndAudios_ = {};
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
