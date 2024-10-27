import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_detector/report/report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bluetooth_detector/settings.dart';

Future<File> get _localFile async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/reports.json');
}

void write(Report report) async {
  final File file = await _localFile;
  final String data = report.toJson().toString();

  // Write the file
  await file.writeAsString('${data}');
  print(data);

  printSuccess("Saved!");
}

Future<Report> readReport() async {
  try {
    return await _localFile.then((file) {
      return file.readAsString().then((fileData) {
        Report report = Report.fromJson(jsonDecode(fileData));
        printSuccess("Loaded report");
        return report;
      });
    });
  } catch (e) {
    printWarning("Failed to load report");
    return Report({});
  }
}

Future<Settings> readSettings() async {
  Settings settings = Settings();
  settings.loadData();
  return settings;
}

void printSuccess(String text) {
  print('\x1B[32m$text\x1B[0m');
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}
