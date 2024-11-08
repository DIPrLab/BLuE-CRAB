part of 'report.dart';

extension Cache on Report {
  void refreshCache(Settings settings) => updateStatistics(data.entries.map((device) => device.value!), settings);

  void updateStatistics(Iterable<Device> devices, Settings settings) {
    timeTravelledStats = _timeTravelledStats(devices, settings);
    distanceTravelledStats = _distanceTravelledStats(devices, settings);
    incidenceStats = _incidenceStats(devices, settings);
    areaStats = _areaStats(devices, settings);
  }

  Stats _areaStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.areas.length));

  Stats _incidenceStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.incidence));

  Stats _timeTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.timeTravelled).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled));
}
