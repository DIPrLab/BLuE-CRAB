part of 'report.dart';

extension Statistics on Report {
  List<num> riskScores(Device device, Settings settings) => [
        (device.timeTravelled(settings.timeThreshold(), settings.windowDuration()).inSeconds, timeTravelledStats),
        (device.incidence(settings.timeThreshold(), settings.windowDuration()), incidenceStats),
        (device.areas(settings.distanceThreshold(), settings.windowDuration()).length, areaStats),
        (device.distanceTravelled(settings.timeThreshold(), settings.windowDuration()), distanceTravelledStats),
      ].map((metric) => metric.$2.zScore(metric.$1)).toList();
}
