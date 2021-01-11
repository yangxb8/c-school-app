import 'package:c_school_app/controller/trackable_controller_interface.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'review_words_controller_track.flamingo.dart';

class ReviewWordsControllerTrack extends ControllerTrack {
  ReviewWordsControllerTrack({
    this.trackedWordId,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String trackedWordId = '';

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}