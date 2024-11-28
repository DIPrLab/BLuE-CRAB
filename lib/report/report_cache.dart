part of 'report.dart';

extension Cache on Report {
  void refreshCache(Settings settings) {
    updateDeviceStatistics(settings);
    updateStatistics(_data.entries.where((entry) => entry.value != null).map((entry) => entry.value!), settings);
  }

  void updateDeviceStatistics(Settings settings) => _data.values.forEach((d) => d?.updateStatistics(settings));

  void updateStatistics(Iterable<Device> devices, Settings settings) {
    timeTravelledStats = _timeTravelledStats(devices, settings);
    distanceTravelledStats = _distanceTravelledStats(devices, settings);
    incidenceStats = _incidenceStats(devices, settings);
    areaStats = _areaStats(devices, settings);
    riskScoreStats = _riskScoreStats(devices, settings);
  }

  Stats _areaStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.areas.length));

  Stats _incidenceStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.incidence));

  Stats _timeTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.timeTravelled).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled));

  Stats _riskScoreStats(Iterable<Device> devices, Settings settings) =>
      Stats.fromData(devices.map((device) => riskScore(device, settings)));
}
