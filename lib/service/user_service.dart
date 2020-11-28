import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import '../model/user.dart';

/*
* This class provide AppState from firebase/shared_preference/others
* It should not expose inner service(_localStorageService etc.) usage!!!
* This service use ApiService and LocalStorageService so they must be
* initialized first!
*/
class UserService extends GetxService {
  static UserService _instance;
  static AppUser user;
  static final ApiService _apiService = Get.find();

  static Future<UserService> getInstance() async {
    if (_instance == null) {
      _instance = UserService();
      user = await _getCurrentUser();
      _listenToFirebaseAuth();
    }
    return _instance;
  }

  static void _listenToFirebaseAuth() {
    _apiService.firebaseAuthApi.listenToFirebaseAuth(_refreshAppUser);
  }

  /// Return Empty AppUser if firebase user is null, otherwise,
  /// return AppUser fetched from firestore
  static Future<AppUser> _getCurrentUser() async {
    if (_apiService.firebaseAuthApi.currentUser.isAnonymous) {
      return AppUser();
    } else {
      return await _apiService.firestoreApi
          .fetchAppUser(firebaseUser: _apiService.firebaseAuthApi.currentUser);
    }
  }

  static void _refreshAppUser(User firebaseUser) {
    _getCurrentUser().then((appUser) => user = appUser);
  }
}
