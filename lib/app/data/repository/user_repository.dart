// 📦 Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/data/model/user/user.dart';
import 'package:c_school_app/app/data/provider/user_provider.dart';

/// Make change directly to currentUser and call Update to save it
class UserRepository extends GetxService {
  static UserRepository? _instance;
  static final UserProvider _provider = UserFirebaseProvider();
  static late AppUser _currentUser;
  static final RxBool isUserLogin = false.obs;

  UserRepository._internal();

  static Future<UserRepository> get instance async {
    if (_instance == null) {
      _instance ??= UserRepository._internal();
      await _refresh();
    }
    return _instance!;
  }

  static Future<void> _refresh() async {
    final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    var dbUser = await _provider.get(firebaseUser?.uid);
    if (dbUser != null) _currentUser = dbUser;
    if (firebaseUser != null) isUserLogin.value = true;
  }

  Future<void> refresh() async => await _refresh();

  AppUser get currentUser => _currentUser;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> update() async {
    await _provider.update(_currentUser);
    await _refresh();
  }

  Future<void> register(AppUser appUser) async {
    await _provider.register(appUser);
    await _refresh();
  }

  /// Refresh AppUser if it existed in db, or register it
  Future<void> registerOrRefresh(AppUser appUser) async {
    var dbUser = await _provider.get(appUser.id);
    if (dbUser == null) {
      await _provider.register(appUser);
      await _refresh();
    } else {
      _currentUser = dbUser;
      isUserLogin.value = true;
    }
  }

  @override
  void onClose() {
    // Commit all change before terminate
    update();
    super.onClose();
  }
}
