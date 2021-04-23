// 📦 Package imports:
// 🌎 Project imports:
import 'package:c_school_app/app/data/model/user/user.dart';
import 'package:c_school_app/app/data/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Make change directly to currentUser and call Update to save it
class UserRepository extends GetxService {
  UserRepository._internal();

  static final RxBool isUserLogin = false.obs;

  late AppUser currentUser;

  static UserRepository? _instance;

  final UserProvider _provider = UserFirebaseProvider();

  @override
  void onClose() {
    // Commit all change before terminate
    update();
    super.onClose();
  }

  static Future<UserRepository> get instance async {
    if (_instance == null) {
      _instance ??= UserRepository._internal();
      await _instance!.refresh();
    }
    return _instance!;
  }

  Future<void> refresh() async {
    final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    var dbUser = await _provider.get(firebaseUser?.uid);
    if (dbUser != null) currentUser = dbUser;
    if (firebaseUser != null && dbUser != null) isUserLogin.value = true;
  }

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> update() async {
    await _provider.update(currentUser);
    await refresh();
  }

  Future<void> register(AppUser appUser) async {
    await _provider.register(appUser);
    await refresh();
  }

  /// Refresh AppUser if it existed in db, or register it
  Future<void> registerOrRefresh(AppUser appUser) async {
    var dbUser = await _provider.get(appUser.id);
    if (dbUser == null) {
      await _provider.register(appUser);
      await refresh();
    } else {
      currentUser = dbUser;
      isUserLogin.value = true;
    }
  }
}
