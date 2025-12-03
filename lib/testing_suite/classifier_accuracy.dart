part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension ClassifierAccuracy on TestingSuite {
  CSVData classifierAccuracy(Report report, Set<String> gt) {
    final CSVData csv = CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList());
    final List<DateTime> timeStamps = report.getTimestamps();
    final List<({int index, DateTime value})> timestamps = generateTimestamps(timeStamps).enumerate().toList();
    timestamps.forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts.value);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      final List<(String, double)> x = Classifier.classifiers.map((classifier) {
        final Iterable<double> results = List.generate(5, (e) {
          final Set<String> flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier).toSet();
          final double recall = flaggedDevices.intersection(gt).length /
              (flaggedDevices.intersection(gt).length +
                  r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length);
          final double precision = flaggedDevices.intersection(gt).length /
              (flaggedDevices.intersection(gt).length + flaggedDevices.difference(gt).length);
          final double f1 = 2 * ((precision * recall) / (precision + recall));
          return f1;
        }).map((e) => e.isNaN ? 0.0 : e);
        return (classifier.name(), results.average);
      }).toList();

      csv.addRow(([ts.value.difference(timeStamps.first).inMinutes.toString()] +
              x.sorted((a, b) => a.$1.compareTo(b.$1)).map((e) => e.$2.toString()).toList())
          .toList());

      final int percentageDone = ((ts.index / timestamps.length) * 100).toInt();
      Logger().i("$percentageDone % - ${ts.index} / ${timestamps.length}");
    });
    return csv;
  }
}
