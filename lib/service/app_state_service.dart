import 'package:get/get.dart';
import 'localstorage_service.dart';
import '../model/system_info.dart';

/*
* This class provide AppState from firebase/shared_preference/others
* It should not expose inner service(_localStorageService etc.) usage!!!
* This service use ApiService and LocalStorageService so they must be
* initialized first!
*/
class AppStateService extends GetxService {
  static AppStateService _instance;
  static SystemInfo systemInfo;
  static final LocalStorageService _localStorageService = Get.find();

  static AppStateService getInstance() {
    if (_instance == null) {
      _instance = AppStateService();
      systemInfo = SystemInfo(
          startCount: _localStorageService.getStartCountAndIncrease());
    }
    return _instance;
  }

  bool get isDebug {
    var debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }
}
