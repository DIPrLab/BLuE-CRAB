part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension ReportMetrics on TestingSuite {
  CSVData getReportMetrics(Report report, SortedList<DateTime> timestamps) {
    final CSVData csv = CSVData([
      "MINUTES_SINCE_INIT",
      "DISTANCE_TRAVELLED",
      "DEVICE_COUNT",
      "DATAPOINT_COUNT",
      "AVERAGE_TIME_WITH_USER",
      "AVERAGE_DISTANCE_WITH_USER",
      "AVERAGE_INCIDENCE_COUNT",
      "AVERAGE_AREA_COUNT",
    ]);
    timestamps.forEach((t) {
      final Report r = report.syntheticReportAtTime(t);

      double avgTimeWithUser;
      try {
        avgTimeWithUser = r.devices().map((d) => d.timeTravelled.inSeconds).average;
      } catch (e) {
        avgTimeWithUser = 0;
      }

      double avgDistanceWithUser;
      try {
        avgDistanceWithUser = r.devices().map((d) => d.distanceTravelled).average;
      } catch (e) {
        avgDistanceWithUser = 0;
      }

      double avgIncidenceCount;
      try {
        avgIncidenceCount = r.devices().map((d) => d.incidence).average;
      } catch (e) {
        avgIncidenceCount = 0;
      }

      double avgAreaCount;
      try {
        avgAreaCount = r.devices().map((d) => d.areaCount).average;
      } catch (e) {
        avgAreaCount = 0;
      }

      csv.addRow([
        t.difference(timestamps.first).inMinutes,
        r.distanceTravelled(),
        r.devices().length,
        r.devices().map((d) => d.dataPoints().length).fold(0, (a, b) => a + b),
        avgTimeWithUser,
        avgDistanceWithUser,
        avgIncidenceCount,
        avgAreaCount,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }
}
