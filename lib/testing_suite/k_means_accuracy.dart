part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension KMeansAccuracy on TestingSuite {
  CSVData getKMeansAccuracy(Report report, Set<String> gt, SortedList<DateTime> timestamps, String filename) {
    final CSVData csv = CSVData([
      "DATASET",
      "MINUTES_SINCE_INIT",
      "K",
      "TRUE_POSITIVES",
      "FALSE_POSITIVES",
      "TRUE_NEGATIVES",
      "FALSE_NEGATIVES",
      "PRECISION",
      "RECALL",
      "F1_SCORE",
    ]);
    timestamps.forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      List.generate(9, (i) => KMeans()..k = i + 2).forEach((classifier) {
        List.generate(100, (i) => i).forEach((index) {
          final Set<String> flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier);

          final int tp = flaggedDevices.intersection(gt).length;
          final int fp = flaggedDevices.difference(gt).length;
          final int fn = r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length;
          final int tn = r.deviceIDs().difference(flaggedDevices).intersection(r.deviceIDs().difference(gt)).length;

          double recall = tp / (tp + fn);
          double precision = tp / (tp + fp);
          double f1 = 2 * ((precision * recall) / (precision + recall));

          recall = recall.isNaN ? 0.0 : recall;
          precision = precision.isNaN ? 0.0 : precision;
          f1 = f1.isNaN ? 0.0 : f1;

          csv.addRow([
            filename,
            ts.difference(timestamps.first).inMinutes,
            classifier.k,
            tp,
            fp,
            tn,
            fn,
            precision,
            recall,
            f1,
          ].map((e) => e.toString()).toList());
        });
      });
    });
    return csv;
  }
}
