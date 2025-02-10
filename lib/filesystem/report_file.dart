part of "package:bluetooth_detector/filesystem/filesystem.dart";

Future<File> get _localReportFile async => _localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

void write(Report report) async => _localReportFile.then((file) => file.writeAsString("${report.toJson().toString()}"));

Future<Report> readReport() async {
  try {
    return await _localReportFile
        .then((file) => file.readAsString().then((fileData) => Report.fromJson(jsonDecode(fileData))));
  } catch (e) {
    printWarning("Failed to load report");
    return Report({});
  }
}

void shareReport() {
  _localReportFile.then((file) {
    file.exists().then((exists) {
      if (exists) {
        Share.shareXFiles([XFile(file.path)], text: "Here is the report file.").then((_) {});
      }
    });
  });
}
