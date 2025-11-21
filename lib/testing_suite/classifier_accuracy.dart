part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension ClassifierAccuracy on TestingSuite {
  CSVData classifierAccuracy(Report report, Set<String> gt) {
    final CSVData csv = CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList());
    final List<DateTime> timeStamps = report.getTimestamps();
    generateTimestamps(timeStamps).forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      final List<(String, double)> x = Classifier.classifiers.map((classifier) {
        final Set<String> flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier).toSet();
        final double recall = flaggedDevices.intersection(gt).length /
            (flaggedDevices.intersection(gt).length +
                r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length);
        final double precision = flaggedDevices.intersection(gt).length /
            (flaggedDevices.intersection(gt).length + flaggedDevices.difference(gt).length);
        final double f1 = 2 * ((precision * recall) / (precision + recall));
        return (classifier.name(), f1);
      }).toList();

      csv.addRow(([ts.difference(timeStamps.first).inMinutes.toString()] +
              x.sorted((a, b) => a.$1.compareTo(b.$1)).map((e) => e.$2.toString()).toList())
          .toList());
    });
    return csv;
  }
}
