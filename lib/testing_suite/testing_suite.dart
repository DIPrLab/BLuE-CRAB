import 'dart:convert';
import 'dart:io';

import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report/datum.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/filesystem/filesystem.dart';

class SQLData {
  List<String> _headers;
  List<List<num>> _rows = [];

  SQLData(this._headers);

  void addRow(List<num> row) => _rows.add(row);
  List<List<num>> getRows() => _rows;

  String toString() => [_headers.join(","), _rows.map((row) => row.join(",")).join("\n")].join("\n");
}

class TestingSuite {
  Report report;
  Set<Device> flaggedDevices = {};
  Map<DateTime, Set<Device>> flaggedDevicesWithTimeStamps = {};
  late List<DateTime> timeStamps;

  TestingSuite(this.report) {
    timeStamps = getTimestamps();
  }

  List<DateTime> generateTimestamps(DateTime start, DateTime end, Duration interval) {
    List<DateTime> timestamps = [start];
    DateTime curr = start.add(interval);

    while (curr.isBefore(end)) {
      timestamps.add(curr);
      curr = curr.add(interval);
    }

    return timestamps;
  }

  List<DateTime> getTimestamps() => report
      .devices()
      .map((d) => d.dataPoints(testing: true).map((d) => d.time).toSet())
      .fold(Set<DateTime>(), (a, b) => a..addAll(b))
      .toList()
    ..sort();

  void test() {
    localFileDirectory.then((dir) => [
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
            .forEach((fileSet) => runTest(fileSet.$1, fileSet.$2, fileSet.$3)));
  }

  void runTest(File inputFile, File csvFile, File logFile) async {
    String jsonData = await inputFile.readAsString();
    this.report = Report.fromJson(jsonDecode(jsonData));
    DateTime init = timeStamps.first;
    DateTime start = init.add(Settings.shared.minScanDuration);
    DateTime end = timeStamps.last;
    SQLData sql = SQLData([
      "SECONDS_SINCE_INIT",
      "DEVICE_COUNT",
      "DATAPOINT_COUNT",
      "RISKY_DEVICE_COUNT",
      "HIGH_RISK_DEVICE_COUNT",
      "LOW_RISK_DEVICE_COUNT"
    ]);
    timeStamps = generateTimestamps(start, end, Settings.shared.scanInterval);
    // print(timeStamps.toString());
    timeStamps.forEach((ts) {
      Map<String, Device> deviceEntries = {};
      Set<Device> filteredDevices =
          report.devices().where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts))).toSet();
      filteredDevices.forEach((d) {
        Set<Datum> dataPoints = d.dataPoints(testing: true).where((dp) => dp.time.isBefore(ts)).toSet();
        deviceEntries[d.id] = Device(d.id, d.name, d.platformName, d.manufacturer, dataPoints: dataPoints);
      });
      if (deviceEntries.length < 2) {
        return;
      }
      Report r = Report(deviceEntries);
      // Stopwatch sw = Stopwatch()..start();
      r.refreshCache();
      // sw.stop();
      sql.addRow([
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
      ]);
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
    });
    // flaggedDevicesWithTimeStamps.forEach(
    //     (timestamp, listOfDevices) => print(timestamp.toString() + ": " + listOfDevices.map((e) => e.id).join(", ")));
    // print("Flagged " + flaggedDevices.length.toString() + " of " + report.devices().length.toString() + " devices");
    print("Printing " + sql.getRows().length.toString());
    csvFile.writeAsString(sql.toString());
  }
}

class FlaggedDevice {
  Device device;
  late DateTime time;

  FlaggedDevice(this.device) {
    this.time = DateTime.now();
  }
}
