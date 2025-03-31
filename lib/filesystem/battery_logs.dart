part of "package:blue_crab/filesystem/filesystem.dart";

Future<File> get _localBatteryLog async => localFileDirectory.then((dir) => File("${dir.path}/battery_log.json"));

Future<void> writeBatteryLog(String data) async => _localBatteryLog.then((file) => file.writeAsString(data));
