// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'localstorage_service.dart';

/*
* This class provide AppState from firebase/shared_preference/others
* It should not expose inner service(_localStorageService etc.) usage!!!
* This service use ApiService and LocalStorageService so they must be
* initialized first!
*/
class AppStateService {
  static final LocalStorageService _localStorageService = Get.find();
  static final startCount = _localStorageService.getStartCountAndIncrease();

  static bool get isDebug {
    var debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }
}
