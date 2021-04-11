// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/ui_view/pinyin_annotated_paragraph.dart';
import 'package:c_school_app/app/ui_view/pronunciation_correction.dart';
import 'package:c_school_app/app/ui_view/speech_evaluation_result.dart';
import '../../app/model/speech_exam.dart';
import '../../c_school_icons.dart';
import 'controller/speech_recording_controller.dart';

class SpeechExamBottomSheet extends StatelessWidget {
  SpeechExamBottomSheet({Key? key, required this.exam}) : super(key: key);

  static const defaultTextStyle = TextStyle();

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
          SimpleGestureDetector(
            onTap: () => controller.playRefSpeech(),
            child: PinyinAnnotatedParagraph(
                paragraph: exam.refText!,
                pinyins: exam.refPinyins!,
                defaultTextStyle: defaultTextStyle),
          ).paddingAll(8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => controller.lastResult.value == null
                ? const SizedBox.shrink()
                : PronunciationCorrection(
                    result: controller.lastResult.value!,
                    refPinyinList: exam.refPinyins!,
                    refHanziList: exam.refText!.split(''),
                    hanziTapCallback: controller.onHanziTap,
                  )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => controller.lastResult.value == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      child: SpeechEvaluationRadialBarChart(
                        sentenceInfo:
                            testData, //TODO: controller.lastResult.value!
                        summaryExpandController:
                            controller.summaryExpandController,
                        detailExpandController:
                            controller.detailExpandController,
                        detailHanziIndex: controller.detailHanziIndex,
                      ),
                    ),
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
      ).paddingSymmetric(horizontal: 20),
    );
  }
}
