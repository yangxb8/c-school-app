// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:supercharged/supercharged.dart';

// 🌎 Project imports:
import '../../app/model/speech_exam.dart';
import '../../c_school_icons.dart';
import 'controller/speech_recording_controller.dart';

class FloatBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  const FloatBottomSheetContainer({Key key, this.child, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showSpeechExamBottomSheet<T>({@required SpeechExam exam}) async {
  final result = await showCustomModalBottomSheet(
    context: Get.context,
    builder: (_) => SpeechExamBottomSheet(exam: exam),
    containerWidget: (_, animation, child) => FloatBottomSheetContainer(
      child: child,
    ),
    expand: false,
    useRootNavigator: true,
    isDismissible: false,
    enableDrag: false,
  );

  return result;
}

class SpeechExamBottomSheet extends StatelessWidget {
  final SpeechExam exam;
  static final int MAX_SPEECHES_SHOWN = 4;

  SpeechExamBottomSheet({Key key, @required this.exam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SpeechRecordingController(exam),
      builder: (controller) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(CSchool.comment_dots),
                IconButton(
                  icon: Icon(CSchool.microphone),
                  onPressed: () => Get.back(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: exam.refText
                  .split('')
                  .mapIndexed((element, index) => SimpleGestureDetector(
                        onTap: () => controller.wordSelected.value = index,
                        child: Text(element).paddingSymmetric(horizontal: 2),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            //TODO: show result properly
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
          ),
          Center(
            child: IconButton(
              icon: Icon(CSchool.microphone),
              onPressed: () => controller.handleRecordButtonPressed(),
              iconSize: 35.0,
            ),
          ),
        ],
      ),
    );
  }
}
