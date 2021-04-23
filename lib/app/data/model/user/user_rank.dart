// 📦 Package imports:
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'user_rank.flamingo.dart';

class UserRank extends Model {
  UserRank({
    this.rank,
    this.timestamp,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @Field()
  int? rank;

  @Field()
  Timestamp? timestamp;
}
