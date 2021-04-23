// 📦 Package imports:

// 🌎 Project imports:
import 'package:c_school_app/app/data/repository/user_repository.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:wiredash/wiredash.dart';

import '../../core/utils/index.dart';

/// Provide user related service, like create and update user
class WiredashService {
  static late final ShakeDetector detector;

  static void startWireDashService() {
    detector = ShakeDetector.autoStart(onPhoneShake: () => showWireDash());
  }

  static void showWireDash() {
    var user = Get.find<UserRepository>().currentUser;
    var firebaseUser = Get.find<UserRepository>().firebaseUser;
    Wiredash.of(Get.context!)!
        .setUserProperties(userId: user.id, userEmail: firebaseUser?.email);
    Wiredash.of(Get.context!)!.show();
  }
}
