part of "package:bluetooth_detector/filesystem/filesystem.dart";

Future<File> get _localBatteryLog async => _localFileDirectory.then((dir) => File("${dir.path}/battery_log.json"));

void writeBatteryLog(String data) async => _localBatteryLog.then((file) => file.writeAsString("${data}"));