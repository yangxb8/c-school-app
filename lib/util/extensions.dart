// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fuzzy/fuzzy.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/service/localstorage_service.dart';
import 'package:c_school_app/util/classes.dart';

extension DateTimeExtension on DateTime {
  String yyyyMMdd() {
    var mm = month < 10 ? '0${month}' : '${month}';
    var dd = day < 10 ? '0${day}' : '${day}';
    return '$this.year$mm$dd';
  }
}

RegExp singleHanziRegExp = RegExp(r'[\u4e00-\u9fa5]{1}',
    caseSensitive: false, multiLine: false, unicode: true);

extension HanziUtil on String {
  bool get isSingleHanzi {
    assert(length == 1);
    return singleHanziRegExp.hasMatch(this);
  }
}

extension StringListUtil on Iterable<String> {
  /// Fuzzy search a list of String by keyword, options can be provided
  List<String> searchFuzzy(String key, {FuzzyOptions options}) {
    options ??=
        FuzzyOptions(findAllMatches: true, tokenize: true, threshold: 0.5);
    final fuse = Fuzzy(toList(), options: options);
    return fuse.search(key).map((r) => r.item.toString());
  }

  /// Search if this string list contains key fuzzily
  bool containsFuzzy(String key, {FuzzyOptions options}) {
    options ??=
        FuzzyOptions(findAllMatches: true, tokenize: true, threshold: 0.5);
    final fuse = Fuzzy(toList(), options: options);
    return fuse.search(key).isNotEmpty;
  }
}

extension StringUtil on String {
  /// Search if this string contains key fuzzily
  bool containsFuzzy(String key, {FuzzyOptions options}) {
    return [this].containsFuzzy(key, options: options);
  }
}

extension WidgetWrapper on Widget {
  Widget statefulWrapper(
      {Function onInit,
      Function afterFirstLayout,
      Function deactivate,
      Function didUpdateWidget,
      Function dispose}) {
    return StatefulWrapper(
      child: this,
      onInit: onInit,
      afterFirstLayout: afterFirstLayout,
      deactivate: deactivate,
      didUpdateWidget: didUpdateWidget,
      dispose: dispose,
    );
  }

  Widget onInit(Function onInit) {
    return StatefulWrapper(child: this, onInit: onInit);
  }

  Widget afterFirstLayout(Function afterFirstLayout) {
    return StatefulWrapper(child: this, afterFirstLayout: afterFirstLayout);
  }
}

extension RxIntExtension on RxInt {
  static final localStorageService = Get.find<LocalStorageService>();

  /// Register a worker to track this RxInt and persist using localstorage.
  RxInt trackLocal(String key) {
    if (localStorageService.containsKey(key)) {
      value = localStorageService.getFromDisk(key);
    }
    debounce(this, (value) => localStorageService.saveToDisk(key, value), time: 1.seconds);
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
    debounce(this, (value) => localStorageService.saveToDisk(key, value),time: 1.seconds);
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
    debounce(this, (value) => localStorageService.saveToDisk(key, value),time: 1.seconds);
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
    debounce(this, (value) => localStorageService.saveToDisk(key, value),time: 1.seconds);
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
    debounce(this, (value) => localStorageService.saveToDisk(key, value),time: 1.seconds);
    return this;
  }
}
