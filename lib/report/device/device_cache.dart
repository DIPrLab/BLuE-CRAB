part of 'device.dart';

extension DeviceCache on Device {
  void updateStatistics(Settings settings) => [
        () => distanceTravelled = _distanceTravelled(settings),
        () => timeTravelled = _timeTravelled(settings),
        () => incidence = _incidence(settings),
        () => areas = _areas(settings),
      ].forEach((f) => f());

  List<Duration> _timeClusterPrefix(Settings settings) => this
      .dataPoints(settings)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .toList();
}
