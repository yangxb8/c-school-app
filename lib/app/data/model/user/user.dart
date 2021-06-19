// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

// 🌎 Project imports:
import 'user_lecture_history.dart';
import 'user_memo.dart';
import 'user_rank.dart';
import 'user_word_history.dart';

// 🌎 Project imports:

part 'user.flamingo.dart';

/*
* User info
 */
class AppUser extends Document<AppUser> {
  AppUser({
    String? id,
    DocumentSnapshot? snapshot,
    Map<String, dynamic>? values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String nickName = '';

  @Field()
  List<String>? _membershipTypes = [];

  @Field()
  Timestamp? membershipEndAt = Timestamp.fromDate(DateTime.now());

  @Field()
  List<String>? likedLectures = [];

  @Field()
  List<String>? likedWords = [];

  @ModelField()
  List<UserRank>? rankHistory = [];

  @ModelField()
  List<LectureHistory>? reviewedClassHistory = [];

  @ModelField()
  List<WordHistory>? reviewedWordHistory = [];

  @ModelField()
  List<UserMemo>? userMemos = [];

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  @override
  Map<String, dynamic> toData() => _$toData(this);

  set membershipTypes(List<MembershipType> types) =>
      _membershipTypes = EnumToString.toList(types);

  List<MembershipType> get membershipTypes =>
      EnumToString.fromList(MembershipType.values, _membershipTypes!)
          as List<MembershipType>;

  int get userRankNow {
    if (rankHistory!.isEmpty) {
      return 1;
    }
    return rankHistory!.last.rank!;
  }

  //TODO: get userScoreCoeff(For speech evaluation) properly
  double get userScoreCoeff => userRankNow.toDouble();
}

enum MembershipType {
  FREE,
  TRIAL,
  SUBSCRIBE, // monthly, yearly etc.
  PACKAGE_BEGINNER // paid for beginner particular package
}