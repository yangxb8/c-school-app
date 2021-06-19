// 🐦 Flutter imports:
// 🌎 Project imports:

// 🌎 Project imports:

// 🐦 Flutter imports:
import '../searchbar_action/toggle_audio_speed.dart';
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
    return GetBuilder(
      init: SpeechEvaluationController(exam),
      builder: (SpeechEvaluationController controller) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(CSchool.comment_dots).paddingAll(8.0),
              ToggleAudioSpeedAction(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Get.back(),
              )
            ],
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
          Obx(() => controller.results.isEmpty
              ? const SizedBox.shrink()
              : PronunciationCorrection(
                  sentenceInfo: controller.results.last,
                  refPinyinList: exam.refPinyins!,
                  refHanziList: exam.refText!,
                  currentFocusedHanziIndex: controller.detailHanziIndex,
                  hanziTapCallback: controller.onResultHanziTap,
                )),
          Obx(
            () => controller.results.isEmpty
                ? const SizedBox.shrink()
                : SpeechEvaluationRadialBarChart(
                    sentenceInfo: controller.results.last,
                    summaryExpandController: controller.summaryExpandController,
                    detailExpandController: controller.detailExpandController,
                    detailHanziIndex: controller.detailHanziIndex,
                  ),
          ),
          IconButton(
            icon: Icon(CSchool.microphone),
            onPressed: () => controller.handleRecordButtonPressed(),
            iconSize: 35.0,
          ),
        ],
      ).paddingOnly(left: 20, right: 20, bottom: 20),
    );
  }
}
