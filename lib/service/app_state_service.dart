import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'localstorage_service.dart';
import 'api_service.dart';
import '../model/user.dart';
import '../model/system_info.dart';

/*
* This class provide AppState from firebase/shared_preference/others
* It should not expose inner service(_localStorageService etc.) usage!!!
* This service use ApiService and LocalStorageService so they must be
* initialized first!
*/
class AppStateService extends GetxService {
  static AppStateService _instance;
  static Rx<AppUser> _user;
  static Rx<SystemInfo> _systemInfo;
  static final LocalStorageService _localStorageService = Get.find();
  static final ApiService _apiService = Get.find();

  static AppStateService getInstance() {
    if (_instance == null) {
      _instance = AppStateService();
      _user = AppUser.fromFirebaseUser(_apiService.firebaseAuthApi.currentUser).obs;
      _systemInfo = SystemInfo(startCount: _localStorageService.getStartCountAndIncrease()).obs;
      _listenToFirebaseAuth();
    }
    return _instance;
  }

  AppUser get user => _user.value;
  SystemInfo get systemInfo => _systemInfo.value;
  bool get isDebug {
    var debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  static void _listenToFirebaseAuth() {
    _apiService.firebaseAuthApi.listenToFirebaseAuth(_refreshAppUser);
  }

  static void _refreshAppUser(User firebaseUser) {
    _user.update((user){
      user.setAppUser(firebaseUser);
    });
  }
}
