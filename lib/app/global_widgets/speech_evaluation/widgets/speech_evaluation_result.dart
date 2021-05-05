// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../data/model/exam/speech_evaluation_result.dart';
import '../../radial_bar_chart.dart';
import '../../expand_box.dart';

// 🌎 Project imports:

class SpeechEvaluationRadialBarChart extends StatelessWidget {
  SpeechEvaluationRadialBarChart(
      {required this.sentenceInfo,
      required this.summaryExpandController,
      required this.detailExpandController,
      required this.detailHanziIndex});

  static const totalScoreStyle = TextStyle(fontSize: 20);
  final ExpandBoxController detailExpandController;
  final RxInt detailHanziIndex;
  final SentenceInfo sentenceInfo;
  final ExpandBoxController summaryExpandController;

  Map<String, double> get sentenceData => {
        'pronAccuracy'.tr: sentenceInfo.displayPronAccuracy,
        'pronCompletion'.tr: sentenceInfo.displayPronCompletion,
        'pronFluency'.tr: sentenceInfo.displayPronFluency
      };

  Map<String, double> hanziData(int index) => {
        'pronAccuracy'.tr: sentenceInfo.words![index].displayPronAccuracy,
        'pronFluency'.tr: sentenceInfo.words![index].displayPronFluency
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandBox(
          controller: summaryExpandController,
          hideArrow: true,
          autoExpand: true,
          child: RadialBarChart(
            title: 'ui.speech.evaluation.result.summary'.tr,
            data: sentenceData,
            maxHeight: 250,
            centerWidget: Text(
              sentenceInfo.displaySuggestedScore.floor().toString(),
              style: totalScoreStyle,
            ),
          ),
        ),
        ExpandBox(
          controller: detailExpandController,
          listener: (AnimationStatus status) {
            if (status == AnimationStatus.forward) {
              // Allow frame started by detail expand to finish render
              Timer.run(summaryExpandController.collapse);
            } else if (status == AnimationStatus.reverse) {
              // Allow frame started by detail expand to finish render
              Timer.run(summaryExpandController.expand);
            }
          },
          child: ObxValue(
              (RxInt index) => RadialBarChart(
                    title: 'ui.speech.evaluation.result.word'.tr,
                    data: hanziData(index.value),
                    maxHeight: 250,
                    centerWidget: Text(
                      sentenceInfo
                          .words![detailHanziIndex.value].displaySuggestedScore
                          .floor()
                          .toString(),
                      style: totalScoreStyle,
                    ),
                  ),
              detailHanziIndex),
        )
      ],
    );
  }
}
