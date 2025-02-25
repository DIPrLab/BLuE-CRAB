import 'dart:async';
import 'dart:io';

import 'package:blue_crab/map_view/map_view.dart';
import 'package:blue_crab/map_view/position.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report_view/report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings_view/settings_view.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:vibration/vibration.dart';
import 'package:latlng/latlng.dart';
import 'package:in_app_notification/in_app_notification.dart';

part 'buttons.dart';
part 'scanner.dart';

class ScannerView extends StatefulWidget {
  ScannerView(Report this.report, {super.key});

  Report report;

  @override
  ScannerViewState createState() => ScannerViewState();
}

class ScannerViewState extends State<ScannerView> {
  LatLng? location;
  late StreamSubscription<Position> positionStream;
  Offset? dragStart;
  double scaleStart = 1.0;

  bool isScanning = false;
  late StreamSubscription<bool> isScanningSubscription;
  late StreamSubscription<List<ScanResult>> scanResultsSubscription;
  List<ScanResult> devices = [];

  late StreamSubscription<DateTime> timeStreamSubscription;

  late Stream<DateTime> _timeStream;

  void enableLocationStream() => positionStream = Geolocator.getPositionStream(
          locationSettings: Controllers.getLocationSettings(Settings.shared.scanDistance().toInt()))
      .listen((Position? position) => setState(() => location = position?.toLatLng()));

  void disableLocationStream() {
    positionStream.pause();
    positionStream.cancel().then((_) => location = null);
  }

  @override
  void initState() {
    super.initState();

    Settings.shared.locationEnabled ? enableLocationStream() : disableLocationStream();

    scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      devices = results;
      results.forEach((d) => widget.report.addDatumToDevice(
          Device(d.device.remoteId.toString(), d.advertisementData.advName, d.device.platformName,
              d.advertisementData.manufacturerData.keys.toList()),
          location,
          d.rssi));
      if (Settings.shared.autoConnect) {
        results.where((d) => d.advertisementData.connectable).forEach((result) => probe(result.device));
      }
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    isScanningSubscription = FlutterBluePlus.isScanning.listen((state) => setState(() => isScanning = state));

    _timeStream = Stream.periodic(Settings.shared.scanTime(), (int x) => DateTime.now());
    timeStreamSubscription = _timeStream.listen((currentTime) => isScanning ? widget.report.refreshCache() : null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Row(children: [
        Expanded(child: SizedBox.shrink()),
        Column(children: [
          Expanded(child: SizedBox.shrink()),
          ...[
            [settingsButton(), reportViewerButton()],
            [notifyButton(), scanButton()],
            [shareButton(), deleteReportButton()]
          ]
              .map((row) => Row(children: row.map((e) => Padding(padding: EdgeInsets.all(16.0), child: e)).toList()))
              .toList(),
          Expanded(child: SizedBox.shrink()),
        ]),
        Expanded(child: SizedBox.shrink()),
      ])));
}
