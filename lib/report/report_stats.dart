part of 'report.dart';

extension Statistics on Report {
  num riskScore(Device device, Settings settings) {
    Iterable<num> data = [
      (device.timeTravelled(settings.timeThreshold()).inSeconds, timeTravelledStats),
      (device.incidence(settings.timeThreshold()), incidenceStats),
      (device.areas(settings.distanceThreshold()).length, areaStats),
      (device.distanceTravelled(settings.timeThreshold()), distanceTravelledStats),
    ].map((metric) => max(0, metric.$2.zScore(metric.$1)));
    num avgResult = Stats.fromData(data).average;
    // num addResult = data.reduce((a, b) => a + b);
    return avgResult;
  }

  Stats _areaStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.areas(settings.distanceThreshold()).length));

  Stats _incidenceStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.incidence(settings.timeThreshold())));

  Stats _timeTravelledStats(Iterable<Device> devices, Settings settings) => Stats.fromData(
      devices.map((device) => device.timeTravelled(settings.timeThreshold())).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled(settings.timeThreshold())));
}
