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
