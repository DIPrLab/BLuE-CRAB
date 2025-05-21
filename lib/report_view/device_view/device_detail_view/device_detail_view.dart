import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/device_map_view.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/property_table_view.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/rssi_graph_view.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class DeviceDetailView extends StatelessWidget {
  DeviceDetailView(this.device, this.report, {super.key});

  final WidgetsToImageController controller = WidgetsToImageController();
  final Device device;
  final Report report;

  Widget header(BuildContext context) => Stack(children: [
        Row(children: [
          BackButton(onPressed: () => Navigator.pop(context), style: buttonWithBackground),
          const Spacer(),
        ]),
        Row(children: [const Spacer(), Text("Device Details", style: titleText), const Spacer()]),
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

  Widget rssiGraphButton(BuildContext context) => TextButton.icon(
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) => SafeArea(child: RssiGraphView(device)))),
      icon: const Icon(Icons.auto_graph),
      label: const Text("RSSI Graph"));

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Column(children: [
                header(context),
                PropertyTable(device, report),
                mapButton(context),
                rssiGraphButton(context),
              ]))));
}
