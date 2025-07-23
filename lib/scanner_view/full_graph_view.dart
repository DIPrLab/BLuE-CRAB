import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/filesystem/dataset.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FullGraphView extends StatelessWidget {
  const FullGraphView(this.report, this.gt, {super.key});

  final Report report;
  final Map<String, List<String>> gt;

  Widget header(BuildContext context) => Stack(children: [
        Row(children: [
          BackButton(onPressed: () => Navigator.pop(context), style: buttonWithBackground),
          const Spacer(),
        ]),
        Row(children: [const Spacer(), Text("All Devices RSSI", style: titleText), const Spacer()]),
      ]);

  Widget graph() {
    final DateTime origin =
        report.devices().map((d) => d.dataPoints().map((dp) => dp.time).sorted((a, b) => a.compareTo(b)).first).first;

    final Set<String> gtMacs = gt[datasetName]?.toSet() ?? {};

    final List<LineChartBarData> dataToGraph = report
        .devices()
        .map((d) => (
              d.id,
              d
                  .dataPoints()
                  .sorted((a, b) => a.time.compareTo(b.time))
                  .smoothedDatumByMovingAverage(const Duration(seconds: 5))
                  .map((dp) => FlSpot(dp.time.difference(origin).inSeconds.toDouble(), dp.rssi.toDouble()))
                  .toList()
            ))
        .map((data) => LineChartBarData(
            dotData: const FlDotData(show: false),
            color: gtMacs.contains(data.$1) ? colors.warnText : colors.safeText,
            spots: data.$2))
        .toList();

    return Scaffold(
        body: LineChart(LineChartData(minY: -100, maxY: 0, lineBarsData: dataToGraph), curve: Curves.easeInOutSine));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Column(children: [
                    header(context),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: SizedBox(height: 540, width: 960, child: graph()))
                  ])))));
}
