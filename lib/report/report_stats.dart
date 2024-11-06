part of 'report.dart';

extension Statistics on Report {
  num riskScore(Device device, Settings settings) {
    Iterable<num> data = [
      (device.timeTravelled(settings.timeThreshold(), settings.windowDuration()).inSeconds, timeTravelledStats),
      (device.incidence(settings.timeThreshold(), settings.windowDuration()), incidenceStats),
      (device.areas(settings.distanceThreshold(), settings.windowDuration()).length, areaStats),
      (device.distanceTravelled(settings.timeThreshold(), settings.windowDuration()), distanceTravelledStats),
    ].map((metric) => max(0, metric.$2.zScore(metric.$1)));
    num avgResult = Stats.fromData(data).average;
    // num addResult = data.reduce((a, b) => a + b);
    return avgResult;
  }

  Stats _areaStats(Iterable<Device> devices, Settings settings) => Stats.fromData(
      devices.map((device) => device.areas(settings.distanceThreshold(), settings.windowDuration()).length));

  Stats _incidenceStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.incidence(settings.timeThreshold(), settings.windowDuration())));

  Stats _timeTravelledStats(Iterable<Device> devices, Settings settings) => Stats.fromData(devices
      .map((device) => device.timeTravelled(settings.timeThreshold(), settings.windowDuration()))
      .map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices, Settings settings) => Stats.fromData(
      devices.map((device) => device.distanceTravelled(settings.timeThreshold(), settings.windowDuration())));
}
