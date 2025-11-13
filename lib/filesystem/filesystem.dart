import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/dataset_formats/compact_dataset/compact_dataset.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/filesystem/dataset.dart';
import 'package:blue_crab/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<Directory> get localFileDirectory async => getApplicationDocumentsDirectory();

Settings readSettings() => Settings()..loadData();

Future<File> get _localReportFile async => localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

Future<void> write(CompactDataset data) async =>
    _localReportFile.then((file) => file.writeAsString("${data.toJson()}"));

Future<Report> readReport() =>
    (kDebugMode ? rootBundle.loadString(datasetToLoad()) : _localReportFile.then((file) => file.readAsString()))
        .then((jsonData) {
      try {
        return Report.fromJson(jsonDecode(jsonData));
      } catch (e) {
        Logger().e("Failed to load report");
        return Report({});
      }
    });

// void shareReport(Report report) {
//   final CompactDataset data = report.toCompactDataset();
//   write(data).then((_) => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)])
//       .then((_) => data.toDB().then((db) => Share.shareXFiles([XFile(db.path)])))));
// }

void shareReport(Report report, BuildContext context) {
  // final box = context.findRenderObject() as RenderBox?;
  // if (box == null || box.hasSize == false) return;
  // final origin = box.localToGlobal(Offset.zero) & box.size;
  final size = MediaQuery.of(context).size;
  final origin = Rect.fromLTWH(0, 0, size.width, kToolbarHeight);
  final CompactDataset data = report.toCompactDataset();
  write(data)
      .then((_) => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)], sharePositionOrigin: origin)));
}

Future<Report> getReportFromFile() => FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    ).then((file) => Report.fromJson(jsonDecode(File(file!.xFiles.first.path).readAsStringSync())));

Future<Report> getReportFromAssets() => rootBundle.loadString(datasetToLoad()).then((jsonData) {
      try {
        return Report.fromJson(jsonDecode(jsonData));
      } catch (e) {
        Logger().e("Failed to load report");
        return Report({});
      }
    });

Future<Map<String, List<String>>> loadGtMacs() async => rootBundle
    .loadString("assets/bledoubt_logs/gt_macs.json")
    .then((content) => jsonDecode(content) as Map<String, dynamic>)
    .then((raw) => raw.map((key, value) => MapEntry(key, (value as List).map((e) => e as String).toList())));
