import 'dart:convert';
import 'dart:io';

import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/testing_suite/csv_data.dart';
import 'package:collection/collection.dart';

part 'package:blue_crab/testing_suite/device_metrics.dart';
part 'package:blue_crab/testing_suite/device_signal_information.dart';
part 'package:blue_crab/testing_suite/flagged_devices_at_time.dart';
part 'package:blue_crab/testing_suite/report_metrics.dart';
part 'package:blue_crab/testing_suite/rssi_metric_data.dart';

class TestingSuite {
  List<DateTime> generateTimestamps(List<DateTime> timestamps) {
    final List<DateTime> result = [];
    DateTime curr = timestamps.first.add(Settings.shared.minScanDuration);

    while (curr.isBefore(timestamps.last) || curr == timestamps.last) {
      result.add(curr);
      curr = curr.add(Settings.shared.scanInterval);
    }
    result.add(timestamps.last);

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

  void testFile(String filename) =>
      localFileDirectory.then((currDir) => loadGtMacs([currDir.path, "gt_macs.json"].join("/")).then((gt) =>
          Directory([currDir.path, "${filename}_reports"].join("/"))
            ..create().then((destDir) => runTest(
                File([currDir.path, "$filename.json"].join("/"))..createSync(),
                gt["$filename.json"]?.toSet() ?? {},
                File([destDir.path, "${filename}_report_data.csv"].join("/"))..createSync(),
                File([destDir.path, "${filename}_device_data.csv"].join("/"))..createSync(),
                File([destDir.path, "${filename}_flagged_devices.csv"].join("/"))..createSync(),
                File([destDir.path, "${filename}_rssi_metrics_5.txt"].join("/"))..createSync(),
                destDir))));

  void runTest(File inputFile, Set<String> groundTruth, File reportDataFile, File deviceDataFile,
      File flaggedDevicesFile, File rssiMetricFile, Directory deviceReportDir) {
    inputFile.readAsString().then((jsonData) {
      print("${inputFile.path}: Checkpoint 0");
      final Report report = Report.fromJson(jsonDecode(jsonData));
      reportDataFile
        ..createSync()
        ..writeAsStringSync(getReportMetrics(report).toString());
      deviceDataFile
        ..createSync()
        print("${inputFile.path}: Checkpoint 5");
        report.devices().forEach((e) => File([deviceReportDir.path, "${e.id}.csv"].join("/"))
        ..writeAsStringSync(getDeviceMetrics(report).toString());
      flaggedDevicesFile
        ..createSync()
        ..writeAsStringSync(getFlaggedDevicesAtTime(report, groundTruth).toString());
      report.devices().forEach((e) => File([deviceReportDir.path, "${e.id}.csv"].join("/"))
        ..createSync(recursive: true)
        ..writeAsStringSync(getDeviceSignalInformation(e).toString()));
      rssiMetricFile
        ..createSync()
        ..writeAsStringSync(getRssiMetricData(report, groundTruth, 5));
    });
  }
}
