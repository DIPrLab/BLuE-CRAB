part of 'report.dart';

extension Cache on Report {
  void refreshCache() {
    _updateDeviceStatistics();
    _updateStatistics(data.entries.map((entry) => entry.value));
    lastUpdated = DateTime.now();
  }

  void _updateDeviceStatistics() {
    Iterable<Device> devices =
        Settings.shared.recentlyChanged ? data.values : data.values.where((d) => d.lastUpdated.isAfter(lastUpdated));
    devices.forEach((d) => d.updateStatistics());
    Settings.shared.recentlyChanged = false;
  }

  void _updateStatistics(Iterable<Device> devices) {
    timeTravelledStats = _timeTravelledStats(devices);
    distanceTravelledStats = _distanceTravelledStats(devices);
    incidenceStats = _incidenceStats(devices);
    areaStats = _areaStats(devices);
    riskScoreStats = _riskScoreStats(devices);
  }

  Stats _areaStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.areas.length));

  Stats _incidenceStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.incidence));

  Stats _timeTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.timeTravelled).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled));

  Stats _riskScoreStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => riskScore(device)));
}
