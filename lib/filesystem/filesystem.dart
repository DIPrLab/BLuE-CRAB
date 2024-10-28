import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_detector/report/report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bluetooth_detector/settings.dart';

part "package:bluetooth_detector/filesystem/report_file.dart";
part "package:bluetooth_detector/filesystem/battery_logs.dart";

Future<Directory> get _localFileDirectory async => await getApplicationDocumentsDirectory();

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
