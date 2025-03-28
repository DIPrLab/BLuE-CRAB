part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension ReportMetrics on TestingSuite {
  CSVData getReportMetrics(Report report) {
    final CSVData csv = CSVData([
      "SECONDS_SINCE_INIT",
      "DEVICE_COUNT",
      "DATAPOINT_COUNT",
      "RISKY_DEVICE_COUNT",
    ]);
    final List<DateTime> timeStamps = report.getTimestamps();
    generateTimestamps(timeStamps).forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.data.entries.length < 2) {
        return;
      }
      r.refreshCache();
      csv.addRow([
        // Time since starting scan
        ts.difference(timeStamps.first).inSeconds,
        // Number of devices in Report
        r.devices().length,
        // Number of data points in Report
        r.devices().map((d) => d.dataPoints().length).fold(0, (a, b) => a + b),
        // Number of risky devices
        r.getSuspiciousDeviceIDs().length,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }
}
