import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part "package:blue_crab/filesystem/report_file.dart";
part "package:blue_crab/filesystem/battery_logs.dart";

Future<Directory> get localFileDirectory async => await getApplicationDocumentsDirectory();

Future<Settings> readSettings() async {
  Settings settings = Settings();
  settings.loadData();
  return settings;
}

void printSuccess(String text) => print('\x1B[32m$text\x1B[0m');

void printWarning(String text) => print('\x1B[33m$text\x1B[0m');

void printError(String text) => print('\x1B[31m$text\x1B[0m');
