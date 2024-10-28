part of "package:bluetooth_detector/filesystem/filesystem.dart";

Future<File> get _localBatteryLog async => _localFileDirectory.then((dir) => File("${dir.path}/battery_log.json"));

void writeBatteryLog(String data) async {
  final File file = await _localReportFile;

  // Write the file
  await file.writeAsString('${data}');
  print(data);

  printSuccess("Saved!");
}
