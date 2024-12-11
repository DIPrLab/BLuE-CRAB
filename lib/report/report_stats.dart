part of 'report.dart';

extension Statistics on Report {
  List<(num, Stats)> riskMetrics(Device device, Settings settings) => [
        settings.enableTimeWithUserMetric ? (device.timeTravelled.inSeconds, timeTravelledStats) : null,
        settings.enableIncidenceMetric ? (device.incidence, incidenceStats) : null,
        settings.enableAreasMetric ? (device.areas.length, areaStats) : null,
        settings.enableDistanceWithUserMetric ? (device.distanceTravelled, distanceTravelledStats) : null,
      ].where((metric) => metric != null).map((metric) => metric!).toList();

  List<(num, Stats)> riskScores(Device device, Settings settings) =>
      riskMetrics(device, settings).map((metric) => (metric.$2.zScore(metric.$1), metric.$2)).toList();

  num riskScore(Device device, Settings settings) =>
      riskScores(device, settings).map((metrics) => metrics.$1).fold(0, (a, b) => a + b);

  int riskTickerScore(Device device, Settings settings) => riskScores(device, settings)
      .map((metric) => metric.$1 > metric.$2.tukeyExtremeUpperLimit
          ? 2
          : metric.$1 > metric.$2.tukeyMildUpperLimit
              ? 1
              : 0)
      .fold(0, (a, b) => a + b);
}
