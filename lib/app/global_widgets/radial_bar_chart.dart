// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:styled_widget/styled_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RadialBarChart extends StatelessWidget {
  const RadialBarChart(
      {this.title,
      required this.data,
      this.centerWidget,
      this.showLegend = true,
      this.showTooltip = true,
      this.maxHeight = double.infinity,
      this.maxWidth = double.infinity,
      this.animationDuration = 500.0});

  /// Widget to show in the center of circle chart
  final Widget? centerWidget;

  /// Name - value pair, value must be normalized to 100 max
  final Map<String, double> data;

  final double maxHeight;
  final double maxWidth;

  /// Whether to show legend
  final bool showLegend;

  /// Whether to show tooltip
  final bool showTooltip;

  /// Title of this table
  final String? title;

  /// Milliseconds
  final double animationDuration;

  List<RadialBarChartData> get chartData =>
      data.entries.map((e) => RadialBarChartData(e)).toList();

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
        title: title == null ? null : ChartTitle(text: title!),
        tooltipBehavior: TooltipBehavior(enable: showTooltip, opacity: 0.7),
        legend: Legend(isVisible: showLegend, toggleSeriesVisibility: false),
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
              widget: centerWidget ?? const SizedBox.shrink())
        ],
        series: <RadialBarSeries<RadialBarChartData, String>>[
          RadialBarSeries<RadialBarChartData, String>(
              dataSource: chartData,
              xValueMapper: (RadialBarChartData data, _) => data.xData,
              yValueMapper: (RadialBarChartData data, _) => data.yData,
              cornerStyle: CornerStyle.bothCurve,
              animationDuration: animationDuration,
              maximumValue: 100),
        ]).constrained(maxWidth: maxWidth, maxHeight: maxHeight);
  }
}

class RadialBarChartData {
  RadialBarChartData(MapEntry<String, double?> titleAndValue)
      : assert(titleAndValue.value == null || titleAndValue.value! <= 100),
        title = titleAndValue.key,
        value = titleAndValue.value ?? -1.0;

  /// Name of the value
  final String title;

  /// Must be converted to double with max value of 100
  final double value;

  /// xData represent the title of this value
  String get xData => title;

  /// yData represent the value of title
  double get yData => value;
}
