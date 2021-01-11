import 'dart:ui';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/cupertino.dart';

class Colors {

  const Colors();

  static final Color loginGradientStart = '#B5D0FA'.toColor();
  static final Color loginGradientEnd = '#484C75'.toColor();

  static final primaryGradient = LinearGradient(
    colors: [loginGradientStart, loginGradientEnd],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}