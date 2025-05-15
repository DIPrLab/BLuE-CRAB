part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension DeviceMetrics on TestingSuite {
  CSVData getDeviceMetrics(Report report) {
    final CSVData csv = CSVData(["DEVICE_MAC", "TIME_WITH_USER", "DISTANCE_WITH_USER"]);
    report
      ..refreshCache()
      ..devices().forEach((d) => csv.addRow([d.id, ...report.riskScores(d).map((e) => e.toString())]));
    return csv;
  }
}
