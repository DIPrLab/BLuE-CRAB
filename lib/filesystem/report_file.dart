part of "package:bluetooth_detector/filesystem/filesystem.dart";

Future<File> get _localReportFile async => _localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

void write(Report report) async {
  final File file = await _localReportFile;
  final String data = report.toJson().toString();

  // Write the file
  await file.writeAsString('${data}');
  print(data);

  printSuccess("Saved!");
}

Future<Report> readReport() async {
  try {
    return await _localReportFile.then((file) {
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
