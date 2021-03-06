// 📦 Package imports:
import 'package:get/get.dart';
import 'package:shake/shake.dart';
import 'package:wiredash/wiredash.dart';

// 🌎 Project imports:
import 'package:c_school_app/service/logger_service.dart';
import '../model/user.dart';
import 'api_service.dart';
import 'lecture_service.dart';

/// Provide user related service, like create and update user
class UserService extends GetxService {
  static UserService _instance;
  static AppUser user;
  static final ApiService _apiService = Get.find();
  static final isLectureServiceInitialized = false.obs;
  static final logger = LoggerService.logger;
  static ShakeDetector detector;

  static Future<UserService> getInstance() async {
    if (_instance == null) {
      _instance = UserService();
      await _refreshAppUser();
      _listenToFirebaseAuth();
      _startWireDashService();
    }
    return _instance;
  }

  static void _listenToFirebaseAuth() {
    _apiService.firebaseAuthApi.listenToFirebaseAuth(_refreshAppUser);
  }

  /// Return Empty AppUser if firebase user is null, otherwise,
  /// return AppUser fetched from firestore
  static Future<AppUser> _getCurrentUser() async {
    final currentUser = await _apiService.firebaseAuthApi.getCurrentUser();
    if (currentUser == null) {
      return AppUser();
    } else {
      return await _apiService.firestoreApi.fetchAppUser(firebaseUser: currentUser);
    }
  }

  static void _refreshAppUser() async {
    user = await _getCurrentUser();
    if (user != null && user.isLogin() && isLectureServiceInitialized.isFalse) {
      await Get.putAsync<LectureService>(() async => await LectureService.getInstance());
      isLectureServiceInitialized.toggle();
    }
  }

  static void commitChange() {
    if (user == null) {
      logger.e('AppUser is not initialized! Commit is canceled');
      return;
    }
    _apiService.firestoreApi.updateAppUser(user, _refreshAppUser);
  }

  static void _startWireDashService() {
    detector = ShakeDetector.autoStart(onPhoneShake: () => showWireDash());
  }

  static void showWireDash() {
    Wiredash.of(Get.context)
        .setUserProperties(userId: user.userId, userEmail: user.firebaseUser.email);
    Wiredash.of(Get.context).show();
  }

  /// Commit any change made to user
  @override
  void onClose() {
    commitChange();
    detector?.stopListening();
    super.onClose();
  }
}
