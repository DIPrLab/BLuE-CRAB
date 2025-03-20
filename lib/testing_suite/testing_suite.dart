import 'dart:convert';
import 'dart:io';

import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';

class CSVData {
  CSVData(this._headers);

  List<String> _headers;
  List<List<String>> _rows = [];

  void addRow(List<String> row) => _rows.add(row);

  String toString() => [_headers.join(","), _rows.map((row) => row.join(",")).join("\n")].join("\n");
}

class TestingSuite {
  // Report report;
  // Set<Device> flaggedDevices = {};
  // Map<DateTime, Set<Device>> flaggedDevicesWithTimeStamps = {};
  // late List<DateTime> timeStamps;

  // TestingSuite(this.report) {
  //   timeStamps = getTimestamps();
  // }

  List<DateTime> generateTimestamps(DateTime start, DateTime end, Duration interval) {
    final List<DateTime> timestamps = [start];
    DateTime curr = start.add(interval);

    while (curr.isBefore(end)) {
      timestamps.add(curr);
      curr = curr.add(interval);
    }

    return timestamps;
  }

  List<DateTime> getTimestamps(Report report) => report
      .devices()
      .map((d) => d.dataPoints(testing: true).map((d) => d.time).toSet())
      .fold(Set<DateTime>(), (a, b) => a..addAll(b))
      .toList()
    ..sort();

  void test() {
    localFileDirectory
        .then((dir) => [
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
            ]
                .map((filename) => (
                      File([dir.path, "${filename}.json"].join("/")),
                      File([dir.path, "${filename}_results.csv"].join("/")),
                      File([dir.path, "${filename}_log.txt"].join("/"))
                    ))
                .forEach((fileSet) => runTest(fileSet.$1, fileSet.$2, fileSet.$3)))
        .then((_) => print("Done!"));
  }

  void runTest(File inputFile, File csvFile, File logFile) {
    final CSVData csv = CSVData([
      "SECONDS_SINCE_INIT",
      "DEVICE_COUNT",
      "DATAPOINT_COUNT",
      "RISKY_DEVICE_COUNT",
      "HIGH_RISK_DEVICE_COUNT",
      "LOW_RISK_DEVICE_COUNT"
    ]);
    inputFile.readAsString().then((jsonData) {
      final Report report = Report.fromJson(jsonDecode(jsonData));
      final List<DateTime> timeStamps = getTimestamps(report);
      generateTimestamps(
              timeStamps.first.add(Settings.shared.minScanDuration), timeStamps.last, Settings.shared.scanInterval)
          .forEach((ts) => logDataAtTime(report, csv, ts, timeStamps.first));
      // flaggedDevicesWithTimeStamps.forEach(
      //     (timestamp, listOfDevices) => print(timestamp.toString() + ": " + listOfDevices.map((e) => e.id).join(", ")));
      // print("Flagged " + flaggedDevices.length.toString() + " of " + report.devices().length.toString() + " devices");
      csvFile.writeAsString(csv.toString());
      logFile.writeAsString(getDeviceMetrics(report).toString());
    });
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

  void logDataAtTime(Report report, CSVData csv, DateTime ts, DateTime init) {
    final Map<String, Device> deviceEntries = {};
    report.devices().where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts))).forEach((d) {
      deviceEntries[d.id] = Device(d.id, d.name, d.platformName, d.manufacturer,
          dataPoints: d.dataPoints(testing: true).where((dp) => dp.time.isBefore(ts)).toSet());
    });
    if (deviceEntries.length < 2) {
      return;
    }
    final Report r = Report(deviceEntries);
    r.refreshCache();
    csv.addRow([
      // Time since starting scan
      ts.difference(init).inSeconds,
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
    // Set<Device> devicesToFlag = filteredDevices.where((d) {
    //   bool a = !flaggedDevices.contains(d);
    //   bool b = r.riskScore(d) > r.riskScoreStats.tukeyExtremeUpperLimit;
    //   return a && b;
    // }).toSet();
    // if (!devicesToFlag.isEmpty) {
    //   if (devicesToFlag.length > 10) {
    //     Duration d = ts.difference(init);
    //     print("Scanned " +
    //         devicesToFlag.length.toString() +
    //         " devices after " +
    //         d.inHours.toString() +
    //         " hours and " +
    //         (d - Duration(hours: d.inHours)).inMinutes.toString() +
    //         " minutes");
    //   }
    //   flaggedDevices.addAll(devicesToFlag);
    //   flaggedDevicesWithTimeStamps[ts] = devicesToFlag;
    // }
  }
}

// class FlaggedDevice {
//   Device device;
//   late DateTime time;

//   FlaggedDevice(this.device) {
//     this.time = DateTime.now();
//   }
// }
