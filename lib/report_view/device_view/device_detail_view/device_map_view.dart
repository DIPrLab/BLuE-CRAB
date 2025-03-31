import 'package:blue_crab/map_view/map_functions.dart';
import 'package:blue_crab/map_view/map_view.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';

class DeviceMapView extends StatefulWidget {
  const DeviceMapView({required this.device, required this.report, super.key});
  final Device device;
  final Report report;

  @override
  DeviceMapViewState createState() => DeviceMapViewState();
}

class DeviceMapViewState extends State<DeviceMapView> {
  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) => Stack(children: [
        MapView(widget.device, MapController(location: middlePoint(widget.device.locations().toList()))),
        BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithBackground),
      ]);
}
