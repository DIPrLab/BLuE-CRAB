part of "package:blue_crab/filesystem/filesystem.dart";

Future<File> get _localReportFile async => localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

void write(Report report) async => _localReportFile.then((file) => file.writeAsString("${report.toJson().toString()}"));

Future<Report> readReport() => (kDebugMode
            ? rootBundle.loadString('assets/bledoubt_logs/validation/bledoubt_log_a.json')
            : _localReportFile.then((file) => file.readAsString()))
        .then((jsonData) {
      try {
        return Report.fromJson(jsonDecode(jsonData));
      } catch (e) {
        printWarning("Failed to load report");
        return Report({});
      }
    });

void shareReport() => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)]).then((_) {}));
