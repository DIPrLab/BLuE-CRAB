import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/collections.dart';
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
    final List<FlSpot> smoothedData = device
        .dataPoints()
        .sorted((a, b) => a.time.compareTo(b.time))
        .smoothedDatumByMovingAverage(const Duration(seconds: 15))
        .map((e) => FlSpot(
            e.time
                .difference(device.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first)
                .inSeconds
                .toDouble(),
            e.rssi.toDouble()))
        .toList();
    final List<FlSpot> realData = device
        .dataPoints()
        .sorted((a, b) => a.time.compareTo(b.time))
        .map((e) => FlSpot(
            e.time
                .difference(device.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first)
                .inSeconds
                .toDouble(),
            e.rssi.toDouble()))
        .toList();
    return Scaffold(
        body: LineChart(
            LineChartData(minY: -100, maxY: 0, lineBarsData: [
              LineChartBarData(dotData: const FlDotData(show: false), color: colors.safeText, spots: smoothedData),
              LineChartBarData(dotData: const FlDotData(show: false), color: colors.warnText, spots: realData),
            ]),
            curve: Curves.easeInOutSine));
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
