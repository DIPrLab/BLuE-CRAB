part of 'report.dart';

extension Statistics on Report {
  // TODO: Remove fold method and replace with device caching
  num riskScore(Device device) => riskScores(device).fold(0, (a, b) => a + b);

  List<num> riskScores(Device device) => ((!Settings.shared.enableTimeWithUserMetric &&
              !Settings.shared.enableIncidenceMetric &&
              !Settings.shared.enableAreasMetric &&
              !Settings.shared.enableDistanceWithUserMetric)
          ? [
              (device.timeTravelled.inSeconds, timeTravelledStats),
              (device.incidence, incidenceStats),
              (device.areas.length, areaStats),
              (device.distanceTravelled, distanceTravelledStats),
            ]
          : [
              if (Settings.shared.enableTimeWithUserMetric) (device.timeTravelled.inSeconds, timeTravelledStats),
              if (Settings.shared.enableIncidenceMetric) (device.incidence, incidenceStats),
              if (Settings.shared.enableAreasMetric) (device.areas.length, areaStats),
              if (Settings.shared.enableDistanceWithUserMetric) (device.distanceTravelled, distanceTravelledStats),
            ])
      .map((metric) => metric.$2.zScore(metric.$1))
      .toList();
}
