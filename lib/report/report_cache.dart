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
    areaStats = _areaStats(devices);
    riskScoreStats = _riskScoreStats(devices);
  }

  Stats _areaStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.areas.length));

  Stats _incidenceStats(Iterable<Device> devices) => Stats.fromData(devices.map((device) => device.incidence));

  Stats _timeTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.timeTravelled).map((duration) => duration.inSeconds));

  Stats _distanceTravelledStats(Iterable<Device> devices) =>
      Stats.fromData(devices.map((device) => device.distanceTravelled));

  Stats _riskScoreStats(Iterable<Device> devices) => Stats.fromData(devices.map(riskScore));
}
