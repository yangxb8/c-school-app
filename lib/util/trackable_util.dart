// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../service/localstorage_service.dart';

extension RxIntExtension on RxInt {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxInt and persist using localstorage.
  RxInt trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      value = localStorageService.getFromDisk(key);
    }
    debounce(
        this, (dynamic value) => localStorageService.saveToDisk(key, value),
        time: 1.seconds);
    return this;
  }
}

extension RxDoubleExtension on RxDouble {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxDouble and persist using localstorage.
  RxDouble trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      value = localStorageService.getFromDisk(key);
    }
    debounce(
        this, (dynamic value) => localStorageService.saveToDisk(key, value),
        time: 1.seconds);
    return this;
  }
}

extension RxBoolExtension on RxBool {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxBool and persist using localstorage.
  RxBool trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      value = localStorageService.getFromDisk(key);
    }
    debounce(
        this, (dynamic value) => localStorageService.saveToDisk(key, value),
        time: 1.seconds);
    return this;
  }
}

extension RxStringExtension on RxString {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxString and persist using localstorage.
  RxString trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      value = localStorageService.getFromDisk(key);
    }
    debounce(
        this, (dynamic value) => localStorageService.saveToDisk(key, value),
        time: 1.seconds);
    return this;
  }
}

extension RxStringListExtension on RxList<String> {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxList<String> and persist using localstorage.
  RxList<String> trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      assignAll(Get.find<LocalStorageService>().getFromDisk(key));
    }
    debounce(
        this, (dynamic value) => localStorageService.saveToDisk(key, value),
        time: 1.seconds);
    return this;
  }
}
