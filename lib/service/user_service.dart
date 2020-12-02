import 'package:get/get.dart';
import 'package:c_school_app/service/logger_service.dart';
import 'api_service.dart';
import '../model/user.dart';

/// Provide user related service, like create and update user
class UserService extends GetxService {
  static UserService _instance;
  static AppUser user;
  static final ApiService _apiService = Get.find();
  static final logger = Get.find<LoggerService>().logger;

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
    if (_apiService.firebaseAuthApi.currentUser.isNull) {
      return AppUser();
    } else {
      return await _apiService.firestoreApi
          .fetchAppUser(firebaseUser: _apiService.firebaseAuthApi.currentUser);
    }
  }

  static void _refreshAppUser() {
    _getCurrentUser().then((appUser) => user = appUser);
  }

  static void commitChange() {
    if(user.isNull){
      logger.e('AppUser is not initialized! Commit is canceled');
      return;
    }
    _apiService.firestoreApi.updateAppUser(user, _refreshAppUser);
  }

  /// Commit any change made to user
  @override
  void onClose() {
    commitChange();
    super.onClose();
  }
}
