part of 'report.dart';

extension Statistics on Report {
  num riskScore(Device device, Settings settings) => Stats.fromData([
        (device.timeTravelled(settings.thresholdTime.toInt()).inSeconds, timeTravelledStats),
        (device.incidence(settings.thresholdTime.toInt()), incidenceStats),
        (device.areas(settings.thresholdDistance).length, areaStats),
        (device.distanceTravelled(settings.thresholdTime.toInt()), distanceTravelledStats),
      ].map((metric) => max(0, metric.$2.zScore(metric.$1)))).average;

  Stats _areaStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.areas(settings.thresholdDistance).length));

  Stats _incidenceStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.incidence(settings.thresholdTime.toInt())));

  Stats _timeTravelledStats(Iterable<Device> devices, Settings settings) => Stats.fromData(devices
      .map((device) => device.timeTravelled(settings.thresholdTime.toInt()))
      .map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled(settings.thresholdTime.toInt())));
}
