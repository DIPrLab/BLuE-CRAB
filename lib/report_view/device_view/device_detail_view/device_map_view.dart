import 'package:blue_crab/map_view/map_functions.dart';
import 'package:blue_crab/map_view/map_view.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';

class DeviceMapView extends StatelessWidget {
  const DeviceMapView({required this.device, required this.report, super.key});

  final Device device;
  final Report report;

  @override
  Widget build(BuildContext context) => Stack(children: [
        MapView(device, MapController(location: middlePoint(device.locations().toList()))),
        BackButton(onPressed: () => Navigator.pop(context), style: buttonWithBackground),
      ]);
}
