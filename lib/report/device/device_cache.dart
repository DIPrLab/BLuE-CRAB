part of 'device.dart';

extension DeviceCache on Device {
  void updateStatistics() => [
        () => distanceTravelled = _distanceTravelled(Settings.shared),
        () => timeTravelled = _timeTravelled(Settings.shared),
        () => incidence = _incidence(Settings.shared),
        () => areas = _areas(Settings.shared),
      ].forEach((f) => f());

  List<Duration> _timeClusterPrefix(Settings settings) => this
      .dataPoints(settings)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .toList();
}
