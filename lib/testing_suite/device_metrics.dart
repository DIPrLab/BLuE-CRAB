part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension DeviceMetrics on TestingSuite {
  CSVData getDeviceMetrics(Report report) {
    final CSVData csv = CSVData(["DEVICE_MAC", "TIME_WITH_USER", "INCIDENCE", "AREAS", "DISTANCE_WITH_USER"]);
    final Map<String, Device> deviceEntries = {};
    report.devices().forEach((d) {
      deviceEntries[d.id] =
          Device(d.id, d.name, d.platformName, d.manufacturer, dataPoints: d.dataPoints(testing: true).toSet());
    });
    final Report r = Report(deviceEntries);
    if (r.devices().length < 2) {
      return csv;
    }
    r.refreshCache();
    r.devices().forEach((d) => csv.addRow([d.id, ...r.riskScores(d).map((e) => e.toString())]));
    return csv;
  }
}
