import 'package:blue_crab/report_view/device_view/device_detail_view/property_table_view.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/device_map_view.dart';
import 'package:flutter/material.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/report/report.dart';

class DeviceDetailView extends StatelessWidget {
  final Device device;
  final Report report;
  final Settings settings;

  DeviceDetailView(this.device, this.report, this.settings);

  Widget header(BuildContext context) => Stack(children: [
        Row(children: [
          BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithBackground),
          Spacer(),
        ]),
        Row(children: [Spacer(), Text("Device Details", style: TextStyles.title), Spacer()]),
      ]);

  Widget mapButton(BuildContext context) => TextButton.icon(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SafeArea(
                      child: DeviceMapView(
                    this.settings,
                    device: device,
                    report: report,
                  )))),
      icon: Icon(Icons.map),
      label: Text("Device Routes"));

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Column(children: [
                header(context),
                PropertyTable(device, report, settings),
                mapButton(context),
              ]))));
}
