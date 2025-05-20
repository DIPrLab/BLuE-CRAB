import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part "package:blue_crab/filesystem/report_file.dart";
part "package:blue_crab/filesystem/battery_logs.dart";

Future<Directory> get localFileDirectory async => getApplicationDocumentsDirectory();

Settings readSettings() => Settings()..loadData();
