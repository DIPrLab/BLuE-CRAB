part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension DeviceRiskFactors on TestingSuite {
  CSVData getDeviceRiskFactors(Device device, SortedList<DateTime> timestamps) {
    final CSVData csv = CSVData([
      "MINUTES_SINCE_INIT",
      "TIME_WITH_USER",
      "DISTANCE_WITH_USER",
      "INCIDENCE_COUNT",
      "AREA_COUNT",
      // "RSSI",
    ]);
    timestamps.forEach((t) {
      final Device d = Device(device.id, device.name, device.platformName, device.manufacturer,
          dataPoints: device
              .dataPoints()
              .where((dp) => dp.time.isBefore(t) || dp.time == t)
              .map((e) => MapEntry(e.time, e))
              .toMap((e) => e.key, (e) => e.value))
        ..updateStatistics();
      csv.addRow([
        t.difference(timestamps.first).inMinutes.toString(),
        d.timeTravelled.inSeconds.toString(),
        d.distanceTravelled.toString(),
        d.incidence.toString(),
        d.areaCount.toString(),
        // d.dataPoints().last.rssi().toString(),
      ]);
    });
    return csv;
  }
}
