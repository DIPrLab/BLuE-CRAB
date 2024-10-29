import 'dart:async';
import 'dart:io';

import 'package:bluetooth_detector/map_view/map_view.dart';
import 'package:bluetooth_detector/map_view/position.dart';
import 'package:bluetooth_detector/filesystem/filesystem.dart';
import 'package:bluetooth_detector/report_view/report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/report/datum.dart';
import 'package:bluetooth_detector/settings_view/settings_view.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:vibration/vibration.dart';
import 'package:latlng/latlng.dart';
import 'package:battery_plus/battery_plus.dart';

part 'package:bluetooth_detector/scanner_view/buttons.dart';
part 'package:bluetooth_detector/scanner_view/scanner.dart';

class ScannerView extends StatefulWidget {
  ScannerView(Report this.report, Settings this.settings, {super.key});

  final Report report;
  final Settings settings;
  final Battery battery = Battery();

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
  List<Device> devices = [];

  late StreamSubscription<DateTime> timeStreamSubscription;

  late Stream<DateTime> _timeStream;

  void log() {
    devices.forEach((Device d) {
      if (!widget.report.data.keys.contains(d.id)) {
        widget.report.data[d.id] = d;
      }
      widget.report.data[d.id]?.dataPoints.add(Datum(location));
    });
    widget.report.refreshCache(widget.settings);
  }

  void enableLocationStream() {
    positionStream = Geolocator.getPositionStream(locationSettings: Controllers.getLocationSettings(30))
        .listen((Position? position) {
      setState(() => location = position?.toLatLng());
      if (isScanning) {
        log();
        rescan();
      }
    });
  }

  void disableLocationStream() {
    location = null;
    positionStream.pause();
    positionStream.cancel();
  }

  @override
  void initState() {
    super.initState();

    widget.settings.locationEnabled ? enableLocationStream() : disableLocationStream();

    scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      devices = results
          .map((ScanResult e) => Device(e.device.remoteId.toString(), e.advertisementData.advName,
              e.device.platformName, e.advertisementData.manufacturerData.keys.toList()))
          .toList();
      results.forEach((result) => probe(result.device));
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    isScanningSubscription = FlutterBluePlus.isScanning.listen((state) => setState(() => isScanning = state));

    _timeStream = Stream.periodic(Duration(seconds: widget.settings.scanTime.toInt()), (int x) => DateTime.now());

    timeStreamSubscription = _timeStream.listen((currentTime) {
      if (isScanning) {
        log();
        rescan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Row(children: [
      Spacer(),
      Column(
        children: [
          Spacer(),
          Row(children: [
            Padding(padding: EdgeInsets.all(16.0), child: settingsButton()),
            Padding(padding: EdgeInsets.all(16.0), child: reportViewerButton()),
          ]),
          Row(children: [
            Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.battery_full)),
            Padding(padding: EdgeInsets.all(16.0), child: scanButton()),
          ]),
          Spacer(),
        ],
      ),
      Spacer(),
    ])));
  }
}
