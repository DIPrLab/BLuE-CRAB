part of "package:bluetooth_detector/filesystem/filesystem.dart";

void writeBatteryReport(String report) async {
  final File file = await _localReportFile;
  final String data = report.toJson().toString();

  // Write the file
  await file.writeAsString('${data}');
  print(data);

  printSuccess("Saved!");
}
