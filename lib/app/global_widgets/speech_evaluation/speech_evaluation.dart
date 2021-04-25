// 🐦 Flutter imports:
// 🌎 Project imports:

// 🌎 Project imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

// 🌎 Project imports:
import '../../core/values/icons/c_school_icons.dart';
import '../../data/model/exam/speech_exam.dart';
import 'speech_evaluation_controller.dart';
import '../pinyin_annotated_paragraph.dart';
import 'widgets/pronunciation_correction.dart';
import 'widgets/speech_evaluation_result.dart';

class SpeechEvaluation extends StatelessWidget {
  SpeechEvaluation({Key? key, required this.exam}) : super(key: key);

  static const defaultTextStyle = TextStyle();

  final SpeechExam exam;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: GetBuilder(
        init: SpeechEvaluationController(exam),
        builder: (SpeechEvaluationController controller) => Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
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
                  paragraph: exam.refTextAsString!,
                  pinyins: exam.refPinyins!,
                  spacing: 5.0,
                  defaultTextStyle: defaultTextStyle,
                  onHanziTap: controller.onRefHanziTap),
            ).paddingAll(8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => controller.lastResult.value == null &&
                      false // TODO: remove false
                  ? const SizedBox.shrink()
                  : PronunciationCorrection(
                      sentenceInfo:
                          testData, //TODO: controller.lastResult.value!,
                      refPinyinList: exam.refPinyins!,
                      refHanziList: exam.refText!,
                      currentFocusedHanziIndex: controller.detailHanziIndex,
                      hanziTapCallback: controller.onResultHanziTap,
                    )),
            ),
            Expanded(
              child: Obx(
                () => controller.lastResult.value == null &&
                        false // TODO: remove false
                    ? const SizedBox.shrink()
                    : SpeechEvaluationRadialBarChart(
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
            IconButton(
              icon: Icon(CSchool.microphone),
              onPressed: () => controller.handleRecordButtonPressed(),
              iconSize: 35.0,
            ),
          ],
        ).paddingOnly(left: 20, right: 20, bottom: 20),
      ),
    );
  }
}
