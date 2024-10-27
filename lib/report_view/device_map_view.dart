import 'package:bluetooth_detector/map_view/map_functions.dart';
import 'package:bluetooth_detector/map_view/map_view.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/styles/styles.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';
import 'package:bluetooth_detector/settings.dart';

class DeviceMapView extends StatefulWidget {
  final Device device;
  final Report report;
  final Settings settings;

  DeviceMapView(Settings this.settings,
      {super.key, required this.device, required this.report});

  @override
  DeviceMapViewState createState() => DeviceMapViewState();
}

class DeviceMapViewState extends State<DeviceMapView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapView(
        widget.device,
        widget.settings,
        controller: MapController(
            location: middlePoint(widget.device.locations().toList())),
      ),
      BackButton(
        onPressed: () => Navigator.pop(context),
        style: AppButtonStyle.buttonWithBackground,
      ),
    ]);
  }
}
