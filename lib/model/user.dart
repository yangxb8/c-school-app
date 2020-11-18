import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spoken_chinese/service/logger_service.dart';
import '../service/api_service.dart';

/*
* Keep tracking latest User info, modify/create user will NOT
* be done through this class.
 */
class AppUser {
  static User _firebaseUser;
  static String nickName;
  static List<MembershipType> membershipTypes;
  static Timestamp membershipEndAt;
  static List<dynamic> rankHistory;
  static Map<String,dynamic> progress;
  static Map<String,dynamic> userGeneratedData;
  static final ApiService _apiService = Get.find();

  AppUser._internal();

  factory AppUser.fromFirebaseUser(User firebaseUser){
    var user = AppUser._internal();
    user.setAppUser(firebaseUser);
    return user;
  }

  bool isLogin() {
    return _firebaseUser != null;
  }

  User get firebaseUser => _firebaseUser;
  String get userId => _firebaseUser?.uid ?? 'NO_FIREBASE_USER';
  int get userRankNow => rankHistory.last['rank'];
  //TODO: get userScoreCoeff(For speech evaluation) properly
  double get userScoreCoeff => userRankNow.toDouble();

  void setAppUser(User firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser.isNull){
      setNullAppUser();
    }
    var appUserMap = await _apiService.firestoreApi.fetchAppUser(firebaseUser: firebaseUser);
    if (appUserMap.isNull){
      setNullAppUser();
    } else {
      nickName = appUserMap['nickname'] as String;
      membershipTypes = EnumToString.fromList(MembershipType.values, appUserMap['membershipType']);
      membershipEndAt = appUserMap['membershipEndAt'] as Timestamp;
      rankHistory = appUserMap['rankHistory'];
      progress = appUserMap['progress'];
      userGeneratedData = appUserMap['userGeneratedData'];
    }
    Get.find<LoggerService>().logger.i(this,'Update User:');
  }

  void setNullAppUser() {
    nickName = null;
    membershipTypes = null;
    membershipEndAt = null;
    rankHistory = null;
    progress = null;
    userGeneratedData = null;
  }
}

enum MembershipType {
  FREE,
  TRIAL,
  SUBSCRIBE, // monthly, yearly etc.
  PACKAGE_BEGINNER // paid for beginner particular package
}
