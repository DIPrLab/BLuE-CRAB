part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension DeviceMetrics on TestingSuite {
  CSVData getDeviceMetrics(Report report) {
    final CSVData csv =
        CSVData(["DEVICE_MAC", "TIME_WITH_USER", "DISTANCE_WITH_USER", "INCIDENCE_COUNT", "AREA_COUNT"]);
    report
      ..refreshCache()
      ..devices().forEach((d) => csv.addRow([
            d.id,
            d.timeTravelled.inSeconds.toString(),
            d.distanceTravelled.toStringAsFixed(2),
            d.incidence.toString(),
            d.areaCount.toString()
          ]));
    return csv;
  }
}
