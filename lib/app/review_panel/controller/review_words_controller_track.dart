import 'package:c_school_app/controller/tracked_controller_interface.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'review_words_controller_track.flamingo.dart';

class ReviewWordsControllerTrack extends Document<ReviewWordsControllerTrack>
    implements ControllerTrackInterface {
  ReviewWordsControllerTrack({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String trackedWordId = '';

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}