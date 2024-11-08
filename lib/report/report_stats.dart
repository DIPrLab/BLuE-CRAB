part of 'report.dart';

extension Statistics on Report {
  // TODO: Remove fold method and replace with device caching
  num riskScore(Device device, Settings settings) => [
        (device.timeTravelled(settings.timeThreshold(), settings.windowDuration()).inSeconds, timeTravelledStats),
        (device.incidence(settings.timeThreshold(), settings.windowDuration()), incidenceStats),
        (device.areas(settings.distanceThreshold(), settings.windowDuration()).length, areaStats),
        (device.distanceTravelled(settings.timeThreshold(), settings.windowDuration()), distanceTravelledStats),
      ].map((metric) => metric.$2.zScore(metric.$1)).toList().fold(0, (a, b) => a + b);
}
