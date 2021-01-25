import 'package:c_school_app/service/localstorage_service.dart';
import 'package:c_school_app/util/classes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

extension WidgetWrapper on Widget {
  Widget statefulWrapper({Function onInit, Function afterFirstLayout}) {
    return StatefulWrapper(
        child: this, onInit: onInit, afterFirstLayout: afterFirstLayout);
  }

  Widget onInit(Function onInit) {
    return StatefulWrapper(child: this, onInit: onInit);
  }

  Widget afterFirstLayout(Function afterFirstLayout) {
    return StatefulWrapper(child: this, onInit: afterFirstLayout);
  }
}

extension RxIntExtension on RxInt {
  static final localStorageService = Get.find<LocalStorageService>();
  /// Register a worker to track this RxInt and persist using localstorage.
  RxInt trackLocal(String key) {
    if(localStorageService.containsKey(key)){
      value = localStorageService.getFromDisk(key);
    }
    ever(this,
        (value) => localStorageService.saveToDisk(key, value));
    return this;
  }
}

extension RxDoubleExtension on RxDouble {
  static final localStorageService = Get.find<LocalStorageService>();
  /// Register a worker to track this RxDouble and persist using localstorage.
  RxDouble trackLocal(String key) {
    if(localStorageService.containsKey(key)){
      value = localStorageService.getFromDisk(key);
    }
    ever(this,
        (value) => localStorageService.saveToDisk(key, value));
    return this;
  }
}

extension RxBoolExtension on RxBool {
  static final localStorageService = Get.find<LocalStorageService>();
  /// Register a worker to track this RxBool and persist using localstorage.
  RxBool trackLocal(String key) {
    if(localStorageService.containsKey(key)){
      value = localStorageService.getFromDisk(key);
    }
    ever(this,
        (value) => localStorageService.saveToDisk(key, value));
    return this;
  }
}

extension RxStringExtension on RxString {
  static final localStorageService = Get.find<LocalStorageService>();
  /// Register a worker to track this RxString and persist using localstorage.
  RxString trackLocal(String key) {
    if(localStorageService.containsKey(key)){
      value = localStorageService.getFromDisk(key);
    }
    ever(this,
        (value) => localStorageService.saveToDisk(key, value));
    return this;
  }
}

extension RxStringListExtension on RxList<String> {
  static final localStorageService = Get.find<LocalStorageService>();
  /// Register a worker to track this RxList<String> and persist using localstorage.
  RxList<String> trackLocal(String key) {
    if(localStorageService.containsKey(key)){
      assignAll(Get.find<LocalStorageService>().getFromDisk(key));
    }
    ever(this,
        (value) => localStorageService.saveToDisk(key, value));
    return this;
  }
}

