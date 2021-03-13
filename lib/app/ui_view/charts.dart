// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpeechEvaluationRadialBarChart extends StatelessWidget {
  /// Must be converted to double with max value of 100
  final double totalScore;
  final List<SpeechEvaluationRadialBarChartData> chartData;

  const SpeechEvaluationRadialBarChart(
      {Key? key, required this.chartData, required this.totalScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
        title: ChartTitle(text: 'ui.charts.summary'.tr),
        legend: Legend(isVisible: true),
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(widget: Text(totalScore.toInt().toString()))
        ],
        series: <RadialBarSeries<SpeechEvaluationRadialBarChartData, String>>[
          RadialBarSeries<SpeechEvaluationRadialBarChartData, String>(
              dataSource: chartData,
              xValueMapper: (SpeechEvaluationRadialBarChartData data, _) =>
                  data.xData,
              yValueMapper: (SpeechEvaluationRadialBarChartData data, _) =>
                  data.yData,
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

  SpeechEvaluationRadialBarChartData(this.title, this.value)
      : assert(value < 100);

  /// xData represent the title of this value
  String get xData => title;
  /// yData represent the value of title
  double get yData => value;
}
