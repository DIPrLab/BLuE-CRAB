import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<Directory> get localFileDirectory async => getApplicationDocumentsDirectory();

Future<Directory> get localPartialsDirectory async =>
    localFileDirectory.then((dir) => Directory([dir.path, "partial_reports"].join("/"))..createSync());

Settings readSettings() => Settings()..loadData();

Future<File> get _localReportFile async => localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

Future<void> write(Report report) async => _localReportFile.then((file) => file.writeAsString("${report.toJson()}"));

Future<void> writePartialReport(Report report) async => localFileDirectory
    .then((dir) => Directory([dir.path, "partial_reports"].join("/"))..createSync())
    .then((dir) => File("${dir.path}/reports_${[
          report.time.year,
          report.time.month,
          report.time.day,
          report.time.hour,
          report.time.minute,
          report.time.second
        ].map((e) => e.toString().padLeft(2, "0")).join("_")}.json")
          ..createSync())
    .then((file) => file.writeAsString("${report.toJson()}"));

Future<Report> readReport() => (kDebugMode
            ? rootBundle.loadString('assets/bledoubt_logs/bledoubt_log_g.json')
            : _localReportFile.then((file) => file.readAsString()))
        .then((jsonData) {
      try {
        return Report.fromJson(jsonDecode(jsonData));
      } catch (e) {
        Logger().e("Failed to load report");
        return Report({});
      }
    });

void deletePartialReports() =>
    localPartialsDirectory.then((dir) => dir.listSync().map((e) => File(e.path)).forEach((e) => e.deleteSync()));

void shareCombinedReport(Report report) => localPartialsDirectory.then((dir) => shareReport(dir
    .listSync()
    .map((e) => File(e.path))
    .map((e) => Report.fromJson(jsonDecode(e.readAsStringSync())))
    .fold(Report({}), (report, partial) => report..combine(partial))));

// void shareReport(Report report) =>
//     write(report).then((_) => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)]).then((_) {})));

void shareReport(Report report) => write(report).then((_) => localPartialsDirectory
    .then((dir) => Share.shareXFiles(dir.listSync().map((e) => XFile(e.path)).toList()).then((_) {})));
