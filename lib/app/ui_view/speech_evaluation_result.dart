// 🐦 Flutter imports:
import 'package:c_school_app/app/ui_view/charts.dart';
import 'package:c_school_app/app/ui_view/expand_box.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import '../model/speech_evaluation_result.dart';

class SpeechEvaluationRadialBarChart extends StatelessWidget {
  SpeechEvaluationRadialBarChart(
      {required this.sentenceInfo,
      required this.summaryExpandController,
      required this.detailExpandController,
      required this.detailHanziIndex});

  final SentenceInfo sentenceInfo;
  final ExpandBoxController summaryExpandController;
  final ExpandBoxController detailExpandController;
  final RxInt detailHanziIndex;

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
            centerWidget: Text(sentenceInfo.displaySuggestedScore.floor().toString()),
          ),
        ),
        ExpandBox(
          controller: detailExpandController,
          listener: (AnimationStatus status) {
            if (status == AnimationStatus.forward) {
              summaryExpandController.collapse();
            } else if (status == AnimationStatus.reverse) {
              summaryExpandController.expand();
            }
          },
          child: ObxValue(
              (RxInt index) => RadialBarChart(
                    title: sentenceInfo.words![detailHanziIndex.value].word,
                    data: hanziData(index.value),
                    maxHeight: 250,
                    centerWidget: Text(sentenceInfo
                        .words![detailHanziIndex.value].displaySuggestedScore
                        .floor()
                        .toString()),
                  ),
              detailHanziIndex),
        )
      ],
    );
  }
}

final testData = SentenceInfo.fromJson({
  'SuggestedScore': 81.13688,
  'PronAccuracy': 81.13688,
  'PronFluency': 0.989831,
  'PronCompletion': 1,
  'RequestId': 'a1c7a233-1398-4621-a73a-61abce43cddd',
  'Words': [
    {
      'MemBeginTime': 440,
      'MemEndTime': 660,
      'PronAccuracy': 76.29468,
      'PronFluency': 0.9774803,
      'ReferenceWord': '',
      'Word': '大',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 440,
          'MemEndTime': 560,
          'PronAccuracy': 67.25144,
          'DetectedStress': false,
          'Phone': 'd',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 560,
          'MemEndTime': 660,
          'PronAccuracy': 85.33791,
          'DetectedStress': false,
          'Phone': 'a4',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 660,
      'MemEndTime': 900,
      'PronAccuracy': 81.862434,
      'PronFluency': 0.9904488,
      'ReferenceWord': '',
      'Word': '家',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 660,
          'MemEndTime': 740,
          'PronAccuracy': 79.22928,
          'DetectedStress': false,
          'Phone': 'j',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 740,
          'MemEndTime': 900,
          'PronAccuracy': 83.17901,
          'DetectedStress': false,
          'Phone': 'ia1',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 900,
      'MemEndTime': 1140,
      'PronAccuracy': 86.209366,
      'PronFluency': 0.99410266,
      'ReferenceWord': '',
      'Word': '好',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 900,
          'MemEndTime': 1000,
          'PronAccuracy': 88.08088,
          'DetectedStress': false,
          'Phone': 'h',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1000,
          'MemEndTime': 1140,
          'PronAccuracy': 85.27361,
          'DetectedStress': false,
          'Phone': 'ao3',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 1140,
      'MemEndTime': 1300,
      'PronAccuracy': 79.47075,
      'PronFluency': 1,
      'ReferenceWord': '',
      'Word': '才',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 1140,
          'MemEndTime': 1210,
          'PronAccuracy': 84.44922,
          'DetectedStress': false,
          'Phone': 'c',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1210,
          'MemEndTime': 1300,
          'PronAccuracy': 76.98152,
          'DetectedStress': false,
          'Phone': 'ai2',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 1300,
      'MemEndTime': 1400,
      'PronAccuracy': 83.41327,
      'PronFluency': 1,
      'ReferenceWord': '',
      'Word': '是',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 1300,
          'MemEndTime': 1360,
          'PronAccuracy': 86.022446,
          'DetectedStress': false,
          'Phone': 'sh',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1360,
          'MemEndTime': 1400,
          'PronAccuracy': 80.804085,
          'DetectedStress': false,
          'Phone': 'i4',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 1400,
      'MemEndTime': 1620,
      'PronAccuracy': 80.26459,
      'PronFluency': 0.99101967,
      'ReferenceWord': '',
      'Word': '真',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 1400,
          'MemEndTime': 1500,
          'PronAccuracy': 78.826675,
          'DetectedStress': false,
          'Phone': 'zh',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1500,
          'MemEndTime': 1620,
          'PronAccuracy': 80.98354,
          'DetectedStress': false,
          'Phone': 'en1',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 1620,
      'MemEndTime': 1700,
      'PronAccuracy': 80.31599,
      'PronFluency': 1,
      'ReferenceWord': '',
      'Word': '的',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 1620,
          'MemEndTime': 1660,
          'PronAccuracy': 79.01269,
          'DetectedStress': false,
          'Phone': 'd',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1660,
          'MemEndTime': 1700,
          'PronAccuracy': 81.61928,
          'DetectedStress': false,
          'Phone': 'e4',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    },
    {
      'MemBeginTime': 1700,
      'MemEndTime': 2060,
      'PronAccuracy': 80.135086,
      'PronFluency': 0.9655962,
      'ReferenceWord': '',
      'Word': '好',
      'MatchTag': 0,
      'PhoneInfos': [
        {
          'MemBeginTime': 1700,
          'MemEndTime': 1810,
          'PronAccuracy': 85.00895,
          'DetectedStress': false,
          'Phone': 'h',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        },
        {
          'MemBeginTime': 1810,
          'MemEndTime': 2060,
          'PronAccuracy': 77.69815,
          'DetectedStress': false,
          'Phone': 'ao3',
          'ReferencePhone': '',
          'Stress': false,
          'MatchTag': 0
        }
      ]
    }
  ]
});
