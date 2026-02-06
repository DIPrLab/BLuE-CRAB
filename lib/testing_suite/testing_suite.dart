import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/classifiers/classifier.dart';
import 'package:blue_crab/classifiers/classifiers.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/testing_suite/csv_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:statistics/statistics.dart';

part 'package:blue_crab/testing_suite/classifier_accuracy.dart';
part 'package:blue_crab/testing_suite/device_risk_factors.dart';
part 'package:blue_crab/testing_suite/flagged_devices_at_time.dart';
part 'package:blue_crab/testing_suite/k_means_accuracy.dart';
part 'package:blue_crab/testing_suite/report_metrics.dart';

class TestingSuite {
  SortedList<DateTime> generateTimestamps(SortedList<DateTime> timestamps, Duration interval) {
    final SortedList<DateTime> result = SortedList<DateTime>();
    DateTime curr = timestamps.first;

    while (curr.isBefore(timestamps.last)) {
      result.add(curr);
      curr = curr.add(interval);
    }
    result.add(timestamps.last);

    return result;
  }

  Future<void> testBleDoubtFiles() async {
    final Map<String, List<String>> gt = await loadGtMacs([(await localFileDirectory).path, "gt_macs.json"].join("/"));
    const String bleDoubtDir = "bledoubt_logs";
    const String bleDoubtDirNoSus = "bledoubt_logs_no_suspicious_devices";
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
      // (bleDoubtDirNoSus, "bledoubt_log_a_a"),
      // (bleDoubtDirNoSus, "bledoubt_log_b_b"),
      // (bleDoubtDirNoSus, "bledoubt_log_c_c"),
      // (bleDoubtDirNoSus, "bledoubt_log_d_d"),
      // (bleDoubtDirNoSus, "bledoubt_log_e_e"),
      // (bleDoubtDirNoSus, "bledoubt_log_f_f"),
      // (bleDoubtDirNoSus, "bledoubt_log_g_g"),
      // (bleDoubtDirNoSus, "bledoubt_log_h_h"),
      // (bleDoubtDirNoSus, "bledoubt_log_i_i"),
      // (bleDoubtDirNoSus, "bledoubt_log_j_j"),
      // (bleDoubtDirNoSus, "bledoubt_log_k_k"),
      // (bleDoubtDirNoSus, "bledoubt_log_l_l"),
      // (bleDoubtDirNoSus, "bledoubt_log_m_m"),
      // (bleDoubtDirNoSus, "bledoubt_log_n_n"),
      (assetsDir, "walking_dataset_1"),
      (assetsDir, "walking_dataset_2"),
      // (assetsDir, "walking_dataset_3"),
      // (assetsDir, "walking_dataset_4"),
      (assetsDir, "bus_dataset_1"),
      // (assetsDir, "bus_dataset_2"),
      // (assetsDir, "driving_dataset_1"),
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

    runTest(report, gt["$dataset.json"]?.toSet() ?? {}, destDir, filename);
  }

  void runTest(Report report, Set<String> groundTruth, Directory deviceReportDir, String filename) {
    final SortedList<DateTime> shortTimestamps = generateTimestamps(report.getTimestamps(), const Duration(minutes: 1));
    final SortedList<DateTime> longTimestamps = generateTimestamps(report.getTimestamps(), const Duration(minutes: 10));

    final CSVData reportData = getReportMetrics(report, shortTimestamps);
    File([deviceReportDir.path, "report_data.csv"].join("/"))
      ..createSync()
      ..writeAsStringSync(reportData.toString());

    report.devices().forEach((device) {
      final CSVData deviceRiskFactorData = getDeviceRiskFactors(device, shortTimestamps);
      File([deviceReportDir.path, "devices", "${device.id}.csv"].join("/"))
        ..createSync(recursive: true)
        ..writeAsStringSync(deviceRiskFactorData.toString());
    });

    final List<({Classifier classifier, CSVData data})> classifierData = Classifier.classifiers
        .map((classifier) =>
            (classifier: classifier, data: getFlaggedDevicesAtTime(report, groundTruth, classifier, shortTimestamps)))
        .toList()
      ..forEach((e) {
        File([deviceReportDir.path, "classifiers", "${e.classifier.csvName()}.csv"].join("/"))
          ..createSync(recursive: true)
          ..writeAsStringSync(e.data.toString());
      });

    // final CSVData e = getKMeansAccuracy(report, groundTruth, shortTimestamps, filename);
    // File([deviceReportDir.path, "K_ACCURACY.csv"].join("/"))
    //   ..createSync(recursive: true)
    //   ..writeAsStringSync(e.toString());

    ["TRUE_POSITIVES", "FALSE_POSITIVES", "TRUE_NEGATIVES", "FALSE_NEGATIVES", "PRECISION", "RECALL", "F1_SCORE"]
        .forEach((column) {
      final key = classifierData.first.data.getColumnByIndex(0);
      final data = classifierData
          .map((e) => e.data.getColumnByName(column)..first = e.classifier.csvName())
          .sorted((a, b) => a.first.compareTo(b.first))
          .toList();
      final CSVData report = CSVData.alt(key, data);
      File([deviceReportDir.path, "metrics", "$column.csv"].join("/"))
        ..createSync(recursive: true)
        ..writeAsStringSync(report.toString());
    });
  }
}
