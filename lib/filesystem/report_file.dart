part of "package:blue_crab/filesystem/filesystem.dart";

Future<File> get _localReportFile async => localFileDirectory.then((dir) => File("${dir.path}/reports.json"));

Future<void> write(Report report) async => _localReportFile.then((file) => file.writeAsString("${report.toJson()}"));

Future<Report> readReport() => (kDebugMode
            ? rootBundle.loadString('assets/bledoubt_logs/bledoubt_log_g.json')
            : _localReportFile.then((file) => file.readAsString()))
        .then((jsonData) {
      try {
        return Report.fromJson(jsonDecode(jsonData));
      } catch (e) {
        Logger().e("Failed to load report");
        return Report({});
      }
    });

void shareReport() => _localReportFile.then((file) => Share.shareXFiles([XFile(file.path)]).then((_) {}));
