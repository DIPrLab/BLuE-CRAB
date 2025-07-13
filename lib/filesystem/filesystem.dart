import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<Directory> get localFileDirectory async => getApplicationDocumentsDirectory();

Settings readSettings() => Settings()..loadData();

Future<File> get _localReportFile async => localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

Future<void> write(Report report) async =>
    _localReportFile.then((file) => file.writeAsString("${report.toCompactDataset().toJson()}"));

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

void shareReport(Report report) =>
    write(report).then((_) => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)]).then((_) {})));

Future<Report> getReportFromFile() => FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    ).then((file) => Report.fromJson(jsonDecode(File(file!.xFiles.first.path).readAsStringSync())));
