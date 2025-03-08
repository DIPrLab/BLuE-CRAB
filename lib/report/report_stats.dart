part of 'report.dart';

extension Statistics on Report {
  // TODO: Remove fold method and replace with device caching
  num riskScore(Device device) => [
        (device.timeTravelled.inSeconds, timeTravelledStats),
        (device.incidence, incidenceStats),
        (device.areas.length, areaStats),
        (device.distanceTravelled, distanceTravelledStats),
      ].map((metric) => metric.$2.zScore(metric.$1)).toList().fold(0, (a, b) => a + b);

  List<num> riskScores(Device device) => [
        (device.timeTravelled.inSeconds, timeTravelledStats),
        (device.incidence, incidenceStats),
        (device.areas.length, areaStats),
        (device.distanceTravelled, distanceTravelledStats),
      ].map((metric) => metric.$2.zScore(metric.$1)).toList();
}
