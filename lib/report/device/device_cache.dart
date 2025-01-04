part of 'device.dart';

extension DeviceCache on Device {
  void updateStatistics(Settings settings) {
    areas = _areas(settings);
    distanceTravelled = _distanceTravelled(settings);
    incidence = _incidence(settings);
    timeTravelled = _timeTravelled(settings);
  }

  List<Duration> _timeClusterPrefix(Settings settings) => this
      .dataPoints(settings)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .toList();
}
