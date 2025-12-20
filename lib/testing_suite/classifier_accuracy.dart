part of 'package:blue_crab/testing_suite/testing_suite.dart';

// extension ClassifierAccuracy on TestingSuite {
//   CSVData classifierAccuracy(Report report, Set<String> gt) {
//     final CSVData csv = CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList());
//     final List<DateTime> timeStamps = report.getTimestamps();
//     final List<({int index, DateTime value})> timestamps = generateTimestamps(timeStamps).enumerate().toList();
//     timestamps.forEach((ts) {
//       final Report r = report.syntheticReportAtTime(ts.value);
//       if (r.devices().length < 2) {
//         return;
//       }
//       r.refreshCache();

//       final List<(String, double)> x = Classifier.classifiers.map((classifier) {
//         final Iterable<double> results = List.generate(100, (e) {
//           final Set<String> flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier).toSet();
//           final double recall = flaggedDevices.intersection(gt).length /
//               (flaggedDevices.intersection(gt).length +
//                   r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length);
//           final double precision = flaggedDevices.intersection(gt).length /
//               (flaggedDevices.intersection(gt).length + flaggedDevices.difference(gt).length);
//           final double f1 = 2 * ((precision * recall) / (precision + recall));
//           return f1;
//         }).map((e) => e.isNaN ? 0.0 : e);
//         return (classifier.name(), results.average);
//       }).toList();

//       csv.addRow(([ts.value.difference(timeStamps.first).inMinutes.toString()] +
//               x.sorted((a, b) => a.$1.compareTo(b.$1)).map((e) => e.$2.toString()).toList())
//           .toList());

//       final int percentageDone = ((ts.index / timestamps.length) * 100).toInt();
//       Logger().i("$percentageDone % - ${ts.index} / ${timestamps.length}");
//     });
//     return csv;
//   }
// }

// extension ClassifierAccuracy on TestingSuite {
//   CSVData classifierAccuracy(Report report, Set<String> groundtruth) {
//     final Set<String> gt = report.deviceIDs().difference(groundtruth);
//     final CSVData csv = CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList());
//     final List<DateTime> timeStamps = report.getTimestamps();
//     final List<({int index, DateTime value})> timestamps = generateTimestamps(timeStamps).enumerate().toList();
//     timestamps.forEach((ts) {
//       final Report r = report.syntheticReportAtTime(ts.value);
//       if (r.devices().length < 2) {
//         return;
//       }
//       r.refreshCache();

//       final List<(String, double)> x = Classifier.classifiers.map((classifier) {
//         final Iterable<double> results = List.generate(100, (e) {
//           final Set<String> flaggedDevices =
//               report.deviceIDs().difference(r.getSuspiciousDeviceIDs(classifier: classifier));

//           final int truePositives = flaggedDevices.intersection(gt).length;
//           final int falsePositives = flaggedDevices.difference(gt).length;
//           final int falseNegatives =
//               r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length;

//           final double recall = truePositives / (truePositives + falseNegatives);
//           final double precision = truePositives / (truePositives + falsePositives);
//           final double f1 = 2 * ((precision * recall) / (precision + recall));
//           return f1;
//         }).map((e) => e.isNaN ? 0.0 : e);
//         return (classifier.name(), results.average);
//       }).toList();

//       csv.addRow(([ts.value.difference(timeStamps.first).inMinutes.toString()] +
//               x.sorted((a, b) => a.$1.compareTo(b.$1)).map((e) => e.$2.toString()).toList())
//           .toList());

//       final int percentageDone = ((ts.index / timestamps.length) * 100).toInt();
//       Logger().i("$percentageDone % - ${ts.index} / ${timestamps.length}");
//     });
//     return csv;
//   }
// }

extension ClassifierAccuracy on TestingSuite {
  ({
    ({CSVData tp, CSVData fp, CSVData fn, CSVData tn}) rawValues,
    ({CSVData precision, CSVData recall, CSVData f1}) results
  }) classifierAccuracy(Report report, Set<String> gt, SortedList<DateTime> timestamps) {
    final ({
      ({CSVData tp, CSVData fp, CSVData fn, CSVData tn}) rawValues,
      ({CSVData precision, CSVData recall, CSVData f1}) results
    }) result = (
      rawValues: (
        tp: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
        fp: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
        fn: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
        tn: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
      ),
      results: (
        precision: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
        recall: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
        f1: CSVData(["MINUTES_SINCE_INIT"] + Classifier.classifiers.map((c) => c.name()).sorted().toList()),
      )
    );

    timestamps.forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      final List<(String, ({double tp, double fp, double fn, double tn, double precision, double recall, double f1}))>
          x = Classifier.classifiers.map((classifier) {
        final ({
          List<int> tp,
          List<int> fp,
          List<int> fn,
          List<int> tn,
          List<double> precision,
          List<double> recall,
          List<double> f1,
        }) results = List.generate(25, (e) {
          final Set<String> flaggedDevices = r.getSuspiciousDeviceIDs(classifier: classifier);

          final int tp = flaggedDevices.intersection(gt).length;
          final int fp = flaggedDevices.difference(gt).length;
          final int fn = r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length;
          final int tn = r.deviceIDs().difference(flaggedDevices).intersection(r.deviceIDs().difference(gt)).length;

          double precision = tp / (tp + fp);
          precision = precision.isNaN ? 0.0 : precision;
          double recall = tp / (tp + fn);
          recall = recall.isNaN ? 0.0 : recall;
          double f1 = 2 * ((precision * recall) / (precision + recall));
          f1 = f1.isNaN ? 0.0 : f1;

          return (tp: tp, fp: fp, fn: fn, tn: tn, precision: precision, recall: recall, f1: f1);
        }).fold(
            (
              tp: List<int>.empty(growable: true),
              fp: List<int>.empty(growable: true),
              fn: List<int>.empty(growable: true),
              tn: List<int>.empty(growable: true),
              precision: List<double>.empty(growable: true),
              recall: List<double>.empty(growable: true),
              f1: List<double>.empty(growable: true),
            ),
            (acc, e) => (
                  tp: acc.tp + [e.tp],
                  fp: acc.fp + [e.fp],
                  fn: acc.fn + [e.fn],
                  tn: acc.tn + [e.tn],
                  precision: acc.precision + [e.precision],
                  recall: acc.recall + [e.recall],
                  f1: acc.f1 + [e.f1],
                ));
        return (
          classifier.name(),
          (
            tp: results.tp.average,
            fp: results.fp.average,
            fn: results.fn.average,
            tn: results.tn.average,
            precision: results.precision.average,
            recall: results.recall.average,
            f1: results.f1.average,
          )
        );
      }).toList();

      final String t = ts.difference(timestamps.first).inMinutes.toString();
      final List<
          (
            String classifier,
            ({double tp, double fp, double fn, double tn, double precision, double recall, double f1})
          )> data = x.sorted((a, b) => a.$1.compareTo(b.$1)).toList();

      result.rawValues.tp.addRow([t] + data.map((e) => e.$2.tp.toString()).toList());
      result.rawValues.fp.addRow([t] + data.map((e) => e.$2.fp.toString()).toList());
      result.rawValues.fn.addRow([t] + data.map((e) => e.$2.fn.toString()).toList());
      result.rawValues.tn.addRow([t] + data.map((e) => e.$2.tn.toString()).toList());

      result.results.precision.addRow([t] + data.map((e) => e.$2.precision.toString()).toList());
      result.results.recall.addRow([t] + data.map((e) => e.$2.recall.toString()).toList());
      result.results.f1.addRow([t] + data.map((e) => e.$2.f1.toString()).toList());

      final int percentageDone = ((timestamps.indexOf(ts) / timestamps.length) * 100).toInt();
      Logger().i("$percentageDone % - ${timestamps.indexOf(ts)} / ${timestamps.length}");
    });
    return result;
  }
}
