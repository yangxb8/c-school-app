import 'package:flutter/foundation.dart';

class SystemInfo {
  final int startCount;

  SystemInfo({@required this.startCount});

  bool get isDebugMode {
    var debugMode = false;
    assert(debugMode = true); // assert will only be run
    return debugMode;
  }
}
