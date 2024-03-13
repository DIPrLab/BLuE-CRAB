import 'package:bluetooth_detector/map_view/map_view.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/styles/colors.dart';
import 'package:bluetooth_detector/styles/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:latlng/latlng.dart';

class DeviceView extends StatelessWidget {
  DeviceIdentifier device;
  Report report;

  DeviceView({super.key, required this.device, required this.report});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapView(markers: [
                            LatLng.degree(45.47233167853709, -122.58916397400984),
                            LatLng.degree(39.288842377026285, -76.64454136029799),
                            LatLng.degree(45.51083352637069, -122.66665975037445),
                          ])));
            },
            style: AppButtonStyle.deviceButtonStyle,
            child: Table(columnWidths: const {
              0: FlexColumnWidth(1.0),
              1: FlexColumnWidth(3.0),
            }, children: [
              TableRow(children: [
                const Text("UUID", style: TextStyle(color: colors.primaryText)),
                Text(report[device]!.device.remoteId.toString(), style: const TextStyle(color: colors.primaryText)),
              ]),
              TableRow(children: [
                const Text("Name", style: TextStyle(color: colors.primaryText)),
                Text(report[device]!.device.advName == "" ? "None" : report[device]!.device.advName,
                    style: const TextStyle(color: colors.primaryText)),
              ]),
              TableRow(children: [
                const Text("Platform", style: TextStyle(color: colors.primaryText)),
                Text(report[device]!.device.platformName == "" ? "Unknown" : report[device]!.device.platformName,
                    style: const TextStyle(color: colors.primaryText)),
              ]),
            ])));
  }
}
