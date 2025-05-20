import 'dart:io';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/device_map_view.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/property_table_view.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class DeviceDetailView extends StatelessWidget {
  DeviceDetailView(this.device, this.report, {super.key});

  final WidgetsToImageController controller = WidgetsToImageController();
  final Device device;
  final Report report;

  Widget header(BuildContext context) => Stack(children: [
        Row(children: [
          BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithBackground),
          const Spacer(),
        ]),
        Row(children: [const Spacer(), Text("Device Details", style: TextStyles.title), const Spacer()]),
      ]);

  Widget mapButton(BuildContext context) => TextButton.icon(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SafeArea(
                      child: DeviceMapView(
                    device: device,
                    report: report,
                  )))),
      icon: const Icon(Icons.map),
      label: const Text("Device Routes"));

  Widget exportButton(BuildContext context) => TextButton.icon(
      onPressed: () async {
        try {
          final data = await controller.capture();
          final dir = await getApplicationDocumentsDirectory();
          final file = File("${dir.path}/output.png");
          await file.writeAsBytes(data!);
          Logger().i("Exported to: ${file.path}");
        } on Exception catch (e) {
          Logger().e("Error capturing image: $e");
        }
      },
      icon: const Icon(Icons.share),
      label: const Text("Export Image"));

  Widget graph() {
    final DateTime origin = device.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first;
    final List<double> timestamps =
        device.dataPoints().map((e) => e.time.difference(origin).inSeconds.toDouble()).toList();
    final List<num> actualRSSI = device.dataPoints().map((e) => e.rssi).toList();
    final List<num> smoothedRSSI =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByMovingAverage(3, SmoothingMethod.padding).toList();
    final List<FlSpot> actualRSSIData =
        List.generate(timestamps.length, (e) => (timestamps[e], actualRSSI[e].toDouble()))
            .map((e) => FlSpot(e.$1, e.$2))
            .toList();
    final List<FlSpot> smoothedRSSIData =
        List.generate(timestamps.length, (e) => (timestamps[e], smoothedRSSI[e].toDouble()))
            .map((e) => FlSpot(e.$1, e.$2))
            .toList();
    return Scaffold(
        body: LineChart(
            LineChartData(minY: -100, maxY: 0, lineBarsData: [
              LineChartBarData(dotData: const FlDotData(show: false), color: Colors.blue, spots: actualRSSIData),
              LineChartBarData(dotData: const FlDotData(show: false), color: Colors.red, spots: smoothedRSSIData),
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
                PropertyTable(device, report),
                mapButton(context),
                WidgetsToImage(controller: controller, child: SizedBox(height: 540, width: 960, child: graph())),
                exportButton(context)
              ]))));
}
