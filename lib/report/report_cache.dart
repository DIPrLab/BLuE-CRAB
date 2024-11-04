part of 'report.dart';

extension Cache on Report {
  void refreshCache(Settings settings) {
    Iterable<Device> devices = data.entries.map((device) => device.value!);

    windowDevices(devices, settings);
    updateStatistics(devices, settings);
  }

  void windowDevices(Iterable<Device> devices, Settings settings) =>
      devices.forEach((device) => device.window(settings));

  void updateStatistics(Iterable<Device> devices, Settings settings) {
    timeTravelledStats = _timeTravelledStats(devices, settings);
    distanceTravelledStats = _distanceTravelledStats(devices, settings);
    incidenceStats = _incidenceStats(devices, settings);
    areaStats = _areaStats(devices, settings);
  }
}
