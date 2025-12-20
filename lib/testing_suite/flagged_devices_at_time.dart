part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension FlaggedDevicesAtTime on TestingSuite {
  CSVData getFlaggedDevicesAtTime(
      Report report, Set<String> gt, Classifier classifier, SortedList<DateTime> timestamps) {
    final CSVData csv = CSVData([
      "MINUTES_SINCE_INIT",
      "TRUE_POSITIVES",
      "FALSE_POSITIVES",
      "TRUE_NEGATIVES",
      "FALSE_NEGATIVES",
      "PRECISION",
      "RECALL",
      "F1_SCORE",
    ]);
    Set<String> flaggedDevices = {};
    timestamps.forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      final ({
        ({List<int> fn, List<int> fp, List<int> tn, List<int> tp}) matrix,
        ({List<double> f1, List<double> precision, List<double> recall}) accuracy,
      }) results = List.generate(25, (index) {
        flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier);

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

        return (maxtrix: (tp: tp, fp: fp, tn: tn, fn: fn), accuracy: (precision: precision, recall: recall, f1: f1));
      }).fold(
          (
            matrix: (
              tp: List<int>.empty(growable: true),
              fp: List<int>.empty(growable: true),
              tn: List<int>.empty(growable: true),
              fn: List<int>.empty(growable: true),
            ),
            accuracy: (
              precision: List<double>.empty(growable: true),
              recall: List<double>.empty(growable: true),
              f1: List<double>.empty(growable: true)
            ),
          ),
          (acc, e) => (
                matrix: (
                  tp: [...acc.matrix.tp, e.maxtrix.tp],
                  fp: [...acc.matrix.fp, e.maxtrix.fp],
                  tn: [...acc.matrix.tn, e.maxtrix.tn],
                  fn: [...acc.matrix.fn, e.maxtrix.fn],
                ),
                accuracy: (
                  precision: [...acc.accuracy.precision, e.accuracy.precision],
                  recall: [...acc.accuracy.recall, e.accuracy.recall],
                  f1: [...acc.accuracy.f1, e.accuracy.f1],
                ),
              ));

      csv.addRow([
        ts.difference(timestamps.first).inMinutes,
        results.matrix.tp.average,
        results.matrix.fp.average,
        results.matrix.tn.average,
        results.matrix.fn.average,
        results.accuracy.precision.average,
        results.accuracy.recall.average,
        results.accuracy.f1.average,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }
}
