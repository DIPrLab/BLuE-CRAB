// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:io';

import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/testing_suite/csv_data.dart';

part 'package:blue_crab/testing_suite/device_metrics.dart';
part 'package:blue_crab/testing_suite/flagged_devices_at_time.dart';
part 'package:blue_crab/testing_suite/report_metrics.dart';

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

  Future<Map<String, List<String>>> loadGtMacs(String path) async => File(path)
      .readAsString()
      .then((content) => jsonDecode(content) as Map<String, dynamic>)
      .then((raw) => raw.map((key, value) => MapEntry(key, (value as List).map((e) => e as String).toList())));

  void testFile(String filename) {
    localFileDirectory.then((dir) => loadGtMacs([dir.path, "gt_macs.json"].join("/")).then((gt) {
          runTest(
              File([dir.path, "${filename}.json"].join("/")),
              File([dir.path, "${filename}_report_data.csv"].join("/")),
              File([dir.path, "${filename}_device_data.csv"].join("/")),
              File([dir.path, "${filename}_flagged_devices.csv"].join("/")),
              gt["${filename}.json"]?.toSet() ?? {});
        }));
  }

  void runTest(
      File inputFile, File reportDataFile, File deviceDataFile, File flaggedDevicesFile, Set<String> groundTruth) {
    inputFile.readAsString().then((jsonData) {
      final Report report = Report.fromJson(jsonDecode(jsonData));
      reportDataFile.writeAsString(getReportMetrics(report).toString());
      deviceDataFile.writeAsString(getDeviceMetrics(report).toString());
      flaggedDevicesFile.writeAsString(getFlaggedDevicesAtTime(report, groundTruth).toString());
    });
  }
}
