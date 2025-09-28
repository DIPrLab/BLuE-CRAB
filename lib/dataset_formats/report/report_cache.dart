part of 'report.dart';

extension Cache on Report {
  void refreshCache() {
    _updateDeviceStatistics();
    _updateStatistics(data.entries.map((entry) => entry.value));
    riskyDevices = Settings.shared.classifier.getRiskyDeviceIDs(this);
    lastUpdated = DateTime.now();
  }

  void _updateDeviceStatistics() {
    Settings.shared.recentlyChanged
        ? data.values
        : data.values.where((d) => d.lastUpdated.isAfter(lastUpdated)).forEach((d) => d.updateStatistics());
    Settings.shared.recentlyChanged = false;
  }

  void _updateStatistics(Iterable<Device> devices) {
    timeTravelledStats = _timeTravelledStats(devices);
    distanceTravelledStats = _distanceTravelledStats(devices);
    incidenceStats = _incidenceStats(devices);
    areaCountStats = _areaCountStats(devices);
    riskScoreStats = _riskScoreStats(devices);
  }

  Stats _incidenceStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.incidence));

  Stats _timeTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.timeTravelled).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled));

  Stats _areaCountStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.areaCount));

  Stats _riskScoreStats(Iterable<Device> devices) => Stats.fromData(devices.map(riskScore));
}
