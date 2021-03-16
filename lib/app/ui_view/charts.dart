// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/speech_evaluation_result.dart';

class RadialBarChart extends StatelessWidget {
  final String title;

  /// Name - value pair, value must be normalized to 100 max
  final Map<String, double> data;

  /// Widget to show in the center of circle chart
  final Widget? centerWidget;
  final bool showLegend;

  const RadialBarChart(
      {this.title = '', required this.data, this.centerWidget, this.showLegend = true});

  List<RadialBarChartData> get chartData =>
      data.entries.map((e) => RadialBarChartData(e)).toList();

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
        title: ChartTitle(text: title),
        legend: Legend(isVisible: showLegend),
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(widget: centerWidget ?? const SizedBox.shrink())
        ],
        series: <RadialBarSeries<RadialBarChartData, String>>[
          RadialBarSeries<RadialBarChartData, String>(
              dataSource: chartData,
              xValueMapper: (RadialBarChartData data, _) => data.xData,
              yValueMapper: (RadialBarChartData data, _) => data.yData,
              cornerStyle: CornerStyle.bothCurve,
              maximumValue: 100),
        ]);
  }
}

class RadialBarChartData {
  /// Name of the value
  final String title;

  /// Must be converted to double with max value of 100
  final double value;

  RadialBarChartData(MapEntry<String, double?> titleAndValue)
      : assert(titleAndValue.value == null || titleAndValue.value! <= 100),
        title = titleAndValue.key,
        value = titleAndValue.value ?? -1.0;

  /// xData represent the title of this value
  String get xData => title;

  /// yData represent the value of title
  double get yData => value;
}
