part of "package:bluetooth_detector/filesystem/filesystem.dart";

Future<File> get _localReportFile async => _localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

void write(Report report) async => _localReportFile.then((file) => file.writeAsString("${report.toJson().toString()}"));

Future<Report> readReport() async {
  String jsonData = "";
  if (kDebugMode) {
    jsonData = await rootBundle.loadString('assets/bledoubt_logs/validation/bledoubt_log_a.json');
  } else {
    jsonData = await _localReportFile.then((file) => file.readAsString());
  }
  try {
    return Report.fromJson(jsonDecode(jsonData));
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

Future<Map<String, dynamic>> loadJsonFromAssets() async {
  try {
    final path = 'assets/sample.json';
    final String jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  } catch (e) {
    throw Exception("Error loading JSON: $e");
  }
}
