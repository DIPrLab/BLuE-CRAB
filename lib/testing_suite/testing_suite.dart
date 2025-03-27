// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:io';

import 'package:blue_crab/ble_doubt_report/ble_doubt_ground_truth.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';

class CSVData {
  CSVData(this._headers);

  final List<String> _headers;
  final List<List<String>> _rows = [];

  void addRow(List<String> row) => _rows.add(row);

  @override
  String toString() => [_headers.join(","), _rows.map((row) => row.join(",")).join("\n")].join("\n");
}

class TestingSuite {
  List<DateTime> generateTimestamps(List<DateTime> timestamps) {
    final List<DateTime> result = [];
    DateTime curr = timestamps.first.add(Settings.shared.minScanDuration);

    while (curr.isBefore(timestamps.last) || curr == timestamps.last) {
      result.add(curr);
      curr = curr.add(Settings.shared.scanInterval);
    }

    return result;
  }

  void testBleDoubtFiles() {
    [
      "bledoubt_log_a",
      "bledoubt_log_b",
      "bledoubt_log_c",
      "bledoubt_log_d",
      "bledoubt_log_e",
      "bledoubt_log_f",
      "bledoubt_log_g",
      "bledoubt_log_h",
      "bledoubt_log_i",
      "bledoubt_log_j",
      "bledoubt_log_k",
      "bledoubt_log_l",
      "bledoubt_log_m",
      "bledoubt_log_n",
    ].forEach(testFile);
  }

  void testFile(String filename) {
    localFileDirectory.then((dir) => runTest(
        File([dir.path, "${filename}.json"].join("/")),
        File([dir.path, "${filename}_report_data.csv"].join("/")),
        File([dir.path, "${filename}_device_data.txt"].join("/")),
        File([dir.path, "${filename}_flagged_devices.csv"].join("/")),
        BleDoubtGroundTruth.fromJson(json.decode(File([dir.path, "gt_macs.json"].join("/")).readAsStringSync()))
                .gt["$filename.json"] ??
            {}));
  }

  void runTest(
      File inputFile, File reportDataFile, File deviceDataFile, File flaggedDevicesFile, Set<String> groundTruth) {
    inputFile.readAsString().then((jsonData) {
      final Report report = Report.fromJson(jsonDecode(jsonData));
      // flaggedDevicesWithTimeStamps.forEach(
      //     (timestamp, listOfDevices) => print(timestamp.toString() + ": " + listOfDevices.map((e) => e.id).join(", ")));
      // print("Flagged " + flaggedDevices.length.toString() + " of " + report.devices().length.toString() + " devices");
      reportDataFile.writeAsString(getReportMetrics(report).toString());
      deviceDataFile.writeAsString(getDeviceMetrics(report).toString());
      flaggedDevicesFile.writeAsString(getFlaggedDevicesAtTime(report, groundTruth).toString());
    });
  }

  CSVData getReportMetrics(Report report) {
    final CSVData csv = CSVData([
      "SECONDS_SINCE_INIT",
      "DEVICE_COUNT",
      "DATAPOINT_COUNT",
      "RISKY_DEVICE_COUNT",
      "HIGH_RISK_DEVICE_COUNT",
      "LOW_RISK_DEVICE_COUNT"
    ]);
    final List<DateTime> timeStamps = report.getTimestamps();
    generateTimestamps(timeStamps).forEach((ts) {
      final Report r = Report(
        Map.fromEntries(report
            .devices()
            .where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts)))
            .map((d) => MapEntry(
                d.id,
                Device(d.id, d.name, d.platformName, d.manufacturer,
                    dataPoints:
                        d.dataPoints(testing: true).where((dp) => dp.time.isBefore(ts) || dp.time == ts).toSet())))),
      )..refreshCache();
      if (r.data.entries.length < 2) {
        return;
      }
      csv.addRow([
        // Time since starting scan
        ts.difference(timeStamps.first).inSeconds,
        // Number of devices in Report
        r.devices().length,
        // Number of data points in Report
        r.devices().map((d) => d.dataPoints().length).fold(0, (a, b) => a + b),
        // Number of risky devices
        r.devices().where((d) => r.riskScore(d) > r.riskScoreStats.tukeyMildUpperLimit).toList().length,
        // Number of high-risk devices
        r.devices().where((d) => r.riskScore(d) > r.riskScoreStats.tukeyExtremeUpperLimit).toList().length,
        // Number of low-risk devices
        r.devices().where((d) => r.riskScore(d) > r.riskScoreStats.tukeyMildUpperLimit).toList().length -
            r.devices().where((d) => r.riskScore(d) > r.riskScoreStats.tukeyExtremeUpperLimit).toList().length,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }

  CSVData getDeviceMetrics(Report report) {
    final CSVData csv = CSVData(["DEVICE_MAC", "TIME_WITH_USER", "INCIDENCE", "AREAS", "DISTANCE_WITH_USER"]);
    final Map<String, Device> deviceEntries = {};
    report.devices().forEach((d) {
      deviceEntries[d.id] =
          Device(d.id, d.name, d.platformName, d.manufacturer, dataPoints: d.dataPoints(testing: true).toSet());
    });
    final Report r = Report(deviceEntries)..refreshCache();
    r.devices().forEach((d) => csv.addRow([d.id, ...r.riskScores(d).map((e) => e.toString())]));
    return csv;
  }

  CSVData getFlaggedDevicesAtTime(Report report, Set<String> gt) {
    final CSVData csv = CSVData([
      "SECONDS_SINCE_INIT",
      "NUMBER_OF_SUSPICIOUS_DEVICES",
      "NUMBER_OF_DEVICES_TO_FLAG",
      "NUMBER_OF_DEVICES_TO_UNFLAG",
      "TRUE_POSITIVES",
      "FALSE_POSITIVES",
      "TRUE_NEGATIVES",
      "FALSE_NEGATIVES",
      "TRUE_POSITIVES_RATE",
      "FALSE_POSITIVES_RATE",
      "TRUE_NEGATIVES_RATE",
      "FALSE_NEGATIVES_RATE",
    ]);
    Set<String> devicesToFlag = {};
    Set<String> devicesToUnflag = {};
    final Set<String> flaggedDevices = {};
    final List<DateTime> timeStamps = report.getTimestamps();
    generateTimestamps(timeStamps).forEach((ts) {
      final Report r = Report(
        Map.fromEntries(report
            .devices()
            .where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts)))
            .map((d) => MapEntry(
                d.id,
                Device(d.id, d.name, d.platformName, d.manufacturer,
                    dataPoints:
                        d.dataPoints(testing: true).where((dp) => dp.time.isBefore(ts) || dp.time == ts).toSet())))),
      )..refreshCache();
      if (r.devices().length < 2) {
        return;
      }

      // Get all suspicious devices not currently flagged and add them to flagged devices
      devicesToFlag = r
          .devices()
          .where((d) => !flaggedDevices.contains(d) && r.riskScore(d) > r.riskScoreStats.tukeyExtremeUpperLimit)
          .map((d) => d.id)
          .toSet();
      flaggedDevices.addAll(devicesToFlag);

      // Get all non-suspicious devices currently flagged and remove them to flagged devices
      devicesToUnflag = r
          .devices()
          .where((d) => flaggedDevices.contains(d) && r.riskScore(d) < r.riskScoreStats.tukeyExtremeUpperLimit)
          .map((d) => d.id)
          .toSet();
      flaggedDevices.removeAll(devicesToUnflag);

      csv.addRow([
        // Time since starting scan
        ts.difference(timeStamps.first).inSeconds,
        // Number of suspicious devices
        flaggedDevices.length,
        // Number of devices to flag
        devicesToFlag.length,
        // Number of devices to un-flag
        devicesToUnflag.length,
        // True positives
        flaggedDevices.intersection(gt).length,
        // False positives
        flaggedDevices.difference(gt).length,
        // True negatives
        r.devices().map((d) => d.id).toSet().intersection(r.devices().map((d) => d.id).toSet().difference(gt)).length,
        // False negatives
        r.devices().map((d) => d.id).toSet().intersection(gt).length,
        // True positive rate
        flaggedDevices.intersection(gt).length / r.devices().length,
        // False positive rate
        flaggedDevices.difference(gt).length / r.devices().length,
        // True negative rate
        r.devices().map((d) => d.id).toSet().intersection(r.devices().map((d) => d.id).toSet().difference(gt)).length /
            r.devices().length,
        // False negative rate
        r.devices().map((d) => d.id).toSet().intersection(gt).length / r.devices().length,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }
}

// class FlaggedDevice {
//   Device device;
//   late DateTime time;

//   FlaggedDevice(this.device) {
//     this.time = DateTime.now();
//   }
// }
