part of 'report.dart';

extension Cache on Report {
  void refreshCache(Settings settings) => updateStatistics(data.entries.map((device) => device.value!), settings);

  void updateStatistics(Iterable<Device> devices, Settings settings) {
    timeTravelledStats = _timeTravelledStats(devices, settings);
    distanceTravelledStats = _distanceTravelledStats(devices, settings);
    incidenceStats = _incidenceStats(devices, settings);
    areaStats = _areaStats(devices, settings);
  }
}
