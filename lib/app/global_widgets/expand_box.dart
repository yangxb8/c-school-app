// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../core/utils/index.dart';

class ExpandBox extends StatelessWidget {
  const ExpandBox({
    Key? key,
    required this.child,
    this.expandHorizontally = false,
    this.duration,
    this.autoExpand = false,
    required this.controller,
    this.listener,
    this.hideArrow = false,
  }) : super(key: key);

  static const default_duration = Duration(milliseconds: 500);

  /// Expand immediately
  final bool autoExpand;

  final Widget child;
  final ExpandBoxController controller;
  final Duration? duration;
  final bool expandHorizontally;

  /// If false, no arrow will be shown, hence expand can only be perform programmatically
  final bool hideArrow;

  final AnimationStatusListener? listener;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => CustomAnimation<double>(
            control: controller.control.value,
            tween: 0.0.tweenTo(1.0),
            duration: duration ?? default_duration,
            curve: Curves.easeInOut,
            animationStatusListener: listener,
            builder: (context, child, value) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: value,
                  child: child,
                ),
              );
            },
            child: child,
          ),
        ),
        hideArrow
            ? const SizedBox.shrink()
            : SimpleGestureDetector(
                onTap: controller.handleTap,
                child: Obx(() => CustomAnimation<double>(
                      control: controller.control.value,
                      tween: 0.0.tweenTo(pi),
                      duration: duration ?? default_duration,
                      builder: (context, child, value) {
                        return Transform.rotate(
                          angle: value,
                          child: child,
                        );
                      },
                      child: const Icon(Icons.arrow_drop_down),
                    )),
              )
      ],
    ).afterFirstLayout(() {
      if (autoExpand) {
        controller.expand();
      }
    });
  }
}

class ExpandBoxController extends GetxController {
  final control = CustomAnimationControl.STOP.obs;
  var expandState = ExpandStatus.collapse;

  @override
  void onInit() {
    ever(control, (state) {
      if (state == CustomAnimationControl.PLAY) {
        expandState = ExpandStatus.expand;
      } else if (state == CustomAnimationControl.PLAY_REVERSE) {
        expandState = ExpandStatus.collapse;
      }
    });
    super.onInit();
  }

  void handleTap() {
    if (expandState == ExpandStatus.collapse) {
      expand();
    } else {
      collapse();
    }
  }

  void expand() => control.value = CustomAnimationControl.PLAY;

  void collapse() => control.value = CustomAnimationControl.PLAY_REVERSE;
}

enum ExpandStatus { expand, collapse }
