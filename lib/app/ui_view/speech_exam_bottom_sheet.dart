// 🐦 Flutter imports:
import 'package:c_school_app/app/ui_view/speech_evaluation_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import '../../app/model/speech_exam.dart';
import '../../c_school_icons.dart';
import 'controller/speech_recording_controller.dart';

class SpeechExamBottomSheet extends StatelessWidget {
  SpeechExamBottomSheet({Key? key, required this.exam}) : super(key: key);

  final SpeechExam exam;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SpeechRecordingController(exam),
      builder: (SpeechRecordingController controller) => Column(
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
            //TODO: remove test Data
            child: SpeechEvaluationRadialBarChart(sentenceInfo: testData,),
          ),
          Center(
            child: IconButton(
              icon: Icon(CSchool.microphone),
              onPressed: () => controller.handleRecordButtonPressed(),
              iconSize: 35.0,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }
}
