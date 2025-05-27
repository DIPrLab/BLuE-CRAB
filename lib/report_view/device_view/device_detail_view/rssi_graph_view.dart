import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RssiGraphView extends StatelessWidget {
  const RssiGraphView(this.device, {super.key});

  final Device device;

  Widget header(BuildContext context) => Stack(children: [
        Row(children: [
          BackButton(onPressed: () => Navigator.pop(context), style: buttonWithBackground),
          const Spacer(),
        ]),
        Row(children: [const Spacer(), Text("Device Details", style: titleText), const Spacer()]),
      ]);

  Widget graph() {
    final DateTime origin = device.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first;
    final List<double> timestamps =
        device.dataPoints().map((e) => e.time.difference(origin).inSeconds.toDouble()).toList();
    final List<num> actualRSSI = device.dataPoints().map((e) => e.rssi).toList();
    final List<num> smoothedRSSI =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByExponentiallyWeightedMovingAverage(0.3).toList();
    final List<num> smoothedRSSI2 =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByMovingAverage(3, SmoothingMethod.padding).toList();
    final List<FlSpot> actualRSSIData =
        List.generate(timestamps.length, (e) => (timestamps[e], actualRSSI[e].toDouble()))
            .map((e) => FlSpot(e.$1, e.$2))
            .toList();
    final List<FlSpot> smoothedRSSIData =
        List.generate(timestamps.length, (e) => (timestamps[e], smoothedRSSI[e].toDouble()))
            .map((e) => FlSpot(e.$1, e.$2))
            .toList();
    final List<FlSpot> smoothedRSSIData2 =
        List.generate(timestamps.length, (e) => (timestamps[e], smoothedRSSI2[e].toDouble()))
            .map((e) => FlSpot(e.$1, e.$2))
            .toList();
    return Scaffold(
        body: LineChart(
            LineChartData(minY: -100, maxY: 0, lineBarsData: [
              LineChartBarData(dotData: const FlDotData(show: false), color: colors.foreground, spots: actualRSSIData),
              LineChartBarData(dotData: const FlDotData(show: false), color: colors.altText, spots: smoothedRSSIData),
              LineChartBarData(dotData: const FlDotData(show: false), color: colors.warnText, spots: smoothedRSSIData2),
            ]),
            curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Column(children: [
                header(context),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: SizedBox(height: 540, width: 960, child: graph()))
              ]))));
}
