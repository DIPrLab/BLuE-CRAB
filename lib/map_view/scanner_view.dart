import 'dart:async';
import 'dart:io';

import 'package:bluetooth_detector/map_view/map_functions.dart';
import 'package:bluetooth_detector/map_view/map_view.dart';
import 'package:bluetooth_detector/map_view/position.dart';
import 'package:bluetooth_detector/report_view/report_view.dart';
import 'package:bluetooth_detector/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:vibration/vibration.dart';
import 'package:latlng/latlng.dart';

part 'package:bluetooth_detector/map_view/buttons.dart';
part 'package:bluetooth_detector/map_view/scanner.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  ScannerViewState createState() => ScannerViewState();
}

class ScannerViewState extends State<ScannerView> {
  LatLng? location;
  late StreamSubscription<Position> positionStream;
  Offset? dragStart;
  double scaleStart = 1.0;
  ReportData reportData = ReportData();

  bool isScanning = false;
  late StreamSubscription<bool> isScanningSubscription;
  late StreamSubscription<List<ScanResult>> scanResultsSubscription;
  List<ScanResult> scanResults = [];
  List<BluetoothDevice> systemDevices = [];

  late StreamSubscription<DateTime> timeStreamSubscription;

  final Stream<DateTime> _timeStream = Stream.periodic(Settings.scanTime, (int x) {
    return DateTime.now();
  });

  void log() {
    reportData.dataPoints.add(DataPoint(location, scanResults));
  }

  void enableLocationStream() {
    positionStream = Geolocator.getPositionStream(locationSettings: Controllers.getLocationSettings(30))
        .listen((Position? position) {
      setState(() {
        location = position?.toLatLng();
      });
      if (isScanning) {
        log();
        rescan();
      }
    });
  }

  void disableLocationStream() {
    positionStream.cancel();
  }

  @override
  void initState() {
    super.initState();

    enableLocationStream();

    scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });

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
      backgroundColor: colors.background,
      body: Center(
          child: Row(children: [
        Spacer(),
        Column(
          children: [
            Spacer(),
            Row(children: [
              // Padding(
              //   padding: EdgeInsets.all(16.0),
              //   child: scanButton(context),
              // ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: locationButton(),
              ),
            ]),
            Row(children: [
              // Padding(
              //   padding: EdgeInsets.all(16.0),
              //   child: locationButton(context),
              // ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: scanButton(),
              ),
            ]),
            Spacer(),
          ],
        ),
        Spacer(),
      ])),
    );
  }
}
