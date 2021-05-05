import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarChart extends StatelessWidget {
  const BarChart({Key? key, required this.data}) : super(key: key);

  /// Name - value pair, value must be normalized to 100 max
  final Map<String, double> data;

  List<BarChartData> get chartData =>
      data.entries.map((e) => BarChartData(e)).toList();

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(series: <ChartSeries>[
      BarSeries<BarChartData, String>(
          dataSource: chartData,
          xValueMapper: (BarChartData data, _) => data.xData,
          yValueMapper: (BarChartData data, _) => data.yData,
          width: 0.6, // Width of the bars
          spacing: 0.3 // Spacing between the bars
          )
    ]);
  }
}

class BarChartData {
  BarChartData(MapEntry<String, double?> titleAndValue)
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
