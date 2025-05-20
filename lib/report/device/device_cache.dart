part of 'device.dart';

extension DeviceCache on Device {
  void updateStatistics() => [
        () => distanceTravelled = _distanceTravelled(),
        () => timeTravelled = _timeTravelled(),
        () => incidence = _incidence(),
      ].forEach((f) => f());

  List<Duration> _timeClusterPrefix() =>
      dataPoints().map((datum) => datum.time).sorted().mapOrderedPairs((pair) => pair.$2.difference(pair.$1)).toList();
}
