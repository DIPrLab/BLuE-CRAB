import 'dart:async';
import 'dart:io';

import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/map_view/map_view.dart';
import 'package:blue_crab/map_view/position.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/report_view.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/settings_view/settings_view.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:blue_crab/testing_suite/testing_suite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:latlng/latlng.dart';
import 'package:vibration/vibration.dart';

part 'buttons.dart';
part 'scanner.dart';

class ScannerView extends StatefulWidget {
  ScannerView(this.report, {super.key});

  Report report;

  @override
  ScannerViewState createState() => ScannerViewState();
}

class ScannerViewState extends State<ScannerView> {
  LatLng? location;
  late StreamSubscription<Position> positionStream;
  Offset? dragStart;
  double scaleStart = 1;
  bool updating = false;

  bool isScanning = false;
  late StreamSubscription<bool> isScanningSubscription;
  late StreamSubscription<List<ScanResult>> scanResultsSubscription;

  late StreamSubscription<DateTime> timeStreamSubscription;

  late Stream<DateTime> _timeStream;
  int deviceCount = 0;
  int datapointCount = 0;

  List<List<(Widget, String)>> buttonList() {
    List<List<(Widget, String)>> result = [
      [(settingsButton(), "Settings"), (reportViewerButton(), "View Report")],
      [(scanButton(), FlutterBluePlus.isScanningNow ? "Stop Scanning" : "Start Scanning")],
    ];
    if (Settings.shared.devMode) {
      result = [
        [(settingsButton(), "Settings"), (reportViewerButton(), "View Report")],
        [(shareButton(), "Share Report"), (deleteReportButton(), "Delete Data")],
        [
          (testButton(), "Run Tests"),
          (scanButton(), FlutterBluePlus.isScanningNow ? "Stop Scanning" : "Start Scanning")
        ],
      ];
    } else if (Settings.shared.demoMode) {
      result = [
        [(settingsButton(), "Settings"), (reportViewerButton(), "View Report")],
        [(loadReportButton(), "Load Sample Data"), (deleteReportButton(), "Delete Data")],
        [(scanButton(), FlutterBluePlus.isScanningNow ? "Stop Scanning" : "Start Scanning")],
      ];
    }
    return result;
  }

  void enableLocationStream() => positionStream = Geolocator.getPositionStream(
          locationSettings: Controllers.getLocationSettings(Settings.shared.scanDistance().toInt()))
      .listen((position) => location = position.toLatLng());

  void disableLocationStream() {
    positionStream.pause();
    positionStream.cancel().then((_) => location = null);
  }

  @override
  void initState() {
    super.initState();

    Settings.shared.locationEnabled ? enableLocationStream() : disableLocationStream();

    scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      results
          .map((sr) => (
                Device(sr.device.remoteId.toString(), sr.advertisementData.advName, sr.device.platformName,
                    sr.advertisementData.manufacturerData.keys.toList()),
                sr.rssi
              ))
          .forEach((d) => widget.report.addDatumToDevice(d.$1, location, d.$2));
      if (Settings.shared.autoConnect) {
        results.where((d) => d.advertisementData.connectable).forEach((result) => probe(result.device));
      }
      deviceCount = widget.report.devices().length;
      datapointCount = widget.report.devices().map((d) => d.dataPoints().length).fold(0, (a, b) => a + b);
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    isScanningSubscription = FlutterBluePlus.isScanning.listen((state) => setState(() => isScanning = state));

    _timeStream = Stream.periodic(Settings.shared.scanTime(), (x) => DateTime.now());
    timeStreamSubscription = _timeStream.listen((currentTime) {
      if (isScanning && !Settings.shared.devMode && !updating) {
        updating = true;
        widget.report.refreshCache();
        updating = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Row(children: [
        const Expanded(child: SizedBox.shrink()),
        Column(children: [
          const Expanded(child: SizedBox.shrink()),
          Text("BL(u)E CRAB",
              // style: GoogleFonts.nothingYouCouldDo(
              // style: GoogleFonts.sniglet(
              // style: GoogleFonts.caprasimo(
              // style: GoogleFonts.mogra(
              style: GoogleFonts.irishGrover(textStyle: TextStyles.splashText)),
          const Expanded(child: SizedBox.shrink()),
          ...buttonList()
              .map((row) => Row(
                  children: row
                      .map((e) =>
                          Column(children: [Padding(padding: const EdgeInsets.all(16), child: e.$1), Text(e.$2)]))
                      .toList()))
              .toList(),
          const Expanded(child: SizedBox.shrink()),
          if (FlutterBluePlus.isScanningNow && Settings.shared.demoMode)
            Text(
                "$deviceCount devices scanned. $datapointCount datapoints. ${widget.report.riskyDevices.length} suspicious devices."),
        ]),
        const Expanded(child: SizedBox.shrink()),
      ])));
}
