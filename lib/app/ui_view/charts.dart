// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/speech_evaluation_result.dart';

class SpeechEvaluationRadialBarChart extends StatelessWidget {
  final SentenceInfo sentenceInfo;

  SpeechEvaluationRadialBarChart({required this.sentenceInfo});

  List<SpeechEvaluationRadialBarChartData> get chartData => {
        'pronAccuracy': sentenceInfo.displayPronAccuracy,
        'pronCompletion': sentenceInfo.displayPronCompletion,
        'pronFluency': sentenceInfo.displayPronFluency
      }.entries.map((e) => SpeechEvaluationRadialBarChartData(e)).toList();

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
        title: ChartTitle(text: 'ui.charts.summary'.tr),
        legend: Legend(isVisible: true),
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
              widget: Text(sentenceInfo.displaySuggestedScore.floor().toString()))
        ],
        series: <RadialBarSeries<SpeechEvaluationRadialBarChartData, String>>[
          RadialBarSeries<SpeechEvaluationRadialBarChartData, String>(
              dataSource: chartData,
              xValueMapper: (SpeechEvaluationRadialBarChartData data, _) => data.xData,
              yValueMapper: (SpeechEvaluationRadialBarChartData data, _) => data.yData,
              cornerStyle: CornerStyle.bothCurve,
              maximumValue: 100),
        ]);
  }
}

class SpeechEvaluationRadialBarChartData {
  /// Name of the value
  final String title;

  /// Must be converted to double with max value of 100
  final double value;

  SpeechEvaluationRadialBarChartData(MapEntry<String, double?> titleAndValue)
      : assert(titleAndValue.value == null || titleAndValue.value! <= 100),
        title = titleAndValue.key,
        value = titleAndValue.value ?? -1.0;

  /// xData represent the title of this value
  String get xData => title;

  /// yData represent the value of title
  double get yData => value;
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
