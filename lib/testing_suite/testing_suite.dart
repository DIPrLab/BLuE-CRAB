import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/classifiers/classifier.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/testing_suite/csv_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

part 'package:blue_crab/testing_suite/device_metrics.dart';
part 'package:blue_crab/testing_suite/device_signal_information.dart';
part 'package:blue_crab/testing_suite/flagged_devices_at_time.dart';
part 'package:blue_crab/testing_suite/report_metrics.dart';
part 'package:blue_crab/testing_suite/classifier_accuracy.dart';

class TestingSuite {
  List<DateTime> generateTimestamps(List<DateTime> timestamps) {
    final List<DateTime> result = [];
    DateTime curr = timestamps.first;

    while (curr.isBefore(timestamps.last)) {
      result.add(curr);
      curr = curr.add(Settings.shared.scanInterval);
    }
    result.add(timestamps.last);

    return result;
  }

  Future<void> testBleDoubtFiles() async {
    final Map<String, List<String>> gt = await loadGtMacs([(await localFileDirectory).path, "gt_macs.json"].join("/"));
    const String bleDoubtDir = "bledoubt_logs";
    const String assetsDir = "datasets";
    await [
      (bleDoubtDir, "bledoubt_log_a"),
      (bleDoubtDir, "bledoubt_log_b"),
      (bleDoubtDir, "bledoubt_log_c"),
      (bleDoubtDir, "bledoubt_log_d"),
      (bleDoubtDir, "bledoubt_log_e"),
      (bleDoubtDir, "bledoubt_log_f"),
      (bleDoubtDir, "bledoubt_log_g"),
      (bleDoubtDir, "bledoubt_log_h"),
      (bleDoubtDir, "bledoubt_log_i"),
      (bleDoubtDir, "bledoubt_log_j"),
      (bleDoubtDir, "bledoubt_log_k"),
      (bleDoubtDir, "bledoubt_log_l"),
      (bleDoubtDir, "bledoubt_log_m"),
      (bleDoubtDir, "bledoubt_log_n"),
      (assetsDir, "walking_dataset_1"),
      (assetsDir, "walking_dataset_2"),
      (assetsDir, "driving_dataset_1"),
    ]
        .map((e) => (e.$2, "assets/${e.$1}/${e.$2}.json", "assets/${e.$1}/gt_macs.json"))
        .forEachAsync((e) async => testFile(e.$1, e.$2, gt));
  }

  Future<Map<String, List<String>>> loadGtMacs(String path) async =>
      (jsonDecode(await File(path).readAsString()) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as List).map((e) => e as String).toList()));

  Future<void> testFile(String dataset, String filename, Map<String, List<String>> gt) async {
    final Report report = Report.fromJson(jsonDecode(await rootBundle.loadString(filename)));
    final Directory currDir = await localFileDirectory;
    final Directory destDir = Directory([currDir.path, "${dataset}_reports"].join("/"))..createSync();

    runTest(
        report,
        gt["$dataset.json"]?.toSet() ?? {},
        File([destDir.path, "${dataset}_report_data.csv"].join("/")),
        File([destDir.path, "${dataset}_device_data.csv"].join("/")),
        File([destDir.path, "${dataset}_flagged_devices.csv"].join("/")),
        File([destDir.path, "${dataset}_classifier_accuracy.csv"].join("/")),
        destDir);
  }

  void runTest(Report report, Set<String> groundTruth, File reportDataFile, File deviceDataFile,
      File flaggedDevicesFile, File classifierAccuracyFile, Directory deviceReportDir) {
    reportDataFile
      ..createSync()
      ..writeAsStringSync(getReportMetrics(report).toString());
    deviceDataFile
      ..createSync()
      ..writeAsStringSync(getDeviceMetrics(report).toString());
    flaggedDevicesFile
      ..createSync()
      ..writeAsStringSync(getFlaggedDevicesAtTime(report, groundTruth).toString());
    report.devices().forEach((e) => File([deviceReportDir.path, "${e.id}.csv"].join("/"))
      ..createSync(recursive: true)
      ..writeAsStringSync(getDeviceSignalInformation(e).toString()));
    classifierAccuracyFile
      ..createSync()
      ..writeAsStringSync(classifierAccuracy(report, groundTruth).toString());
  }
}
