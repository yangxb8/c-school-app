// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import '../../app/model/speech_exam.dart';
import '../../c_school_icons.dart';
import 'controller/speech_recording_controller.dart';

class SpeechExamBottomSheet extends StatelessWidget {
  final SpeechExam exam;
  static final int MAX_SPEECHES_SHOWN = 4;

  SpeechExamBottomSheet({Key? key, required this.exam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SpeechRecordingController(exam),
      builder: (dynamic controller) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(CSchool.comment_dots),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: exam.refText!
                  .split('')
                  .mapIndexed((index, element) => SimpleGestureDetector(
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
      ).borderRadius(all: 12).paddingSymmetric(horizontal: 20),
    );
  }
}
