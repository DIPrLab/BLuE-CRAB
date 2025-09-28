part of 'report.dart';

extension Statistics on Report {
  num riskScore(Device device) => riskScores(device).fold(0, (a, b) => a + b);

  List<num> riskScores(Device device) => ((!Settings.shared.enableTimeWithUserMetric &&
              !Settings.shared.enableIncidenceMetric &&
              !Settings.shared.enableDistanceWithUserMetric)
          ? [
              (device.timeTravelled.inSeconds, timeTravelledStats),
              (device.incidence, incidenceStats),
              (device.distanceTravelled, distanceTravelledStats),
              (device.areaCount, areaCountStats),
            ]
          : [
              if (Settings.shared.enableTimeWithUserMetric) (device.timeTravelled.inSeconds, timeTravelledStats),
              if (Settings.shared.enableIncidenceMetric) (device.incidence, incidenceStats),
              if (Settings.shared.enableDistanceWithUserMetric) (device.distanceTravelled, distanceTravelledStats),
              if (Settings.shared.enableAreaCountMetric) (device.areaCount, areaCountStats),
            ])
      .map((metric) => metric.$2.zScore(metric.$1))
      .toList();
}
