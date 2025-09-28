part of 'device.dart';

extension DeviceStats on Device {
  List<Duration> _timeClusterPrefix() => dataPoints()
      .map((datum) => datum.time)
      .sorted()
      .fold(
          List<(DateTime, DateTime)>.empty(),
          (acc, curr) => acc.isEmpty
              ? [(curr, curr)]
              : curr.difference(acc.last.$2) > Settings.shared.timeThreshold()
                  ? acc + [(curr, curr)]
                  : (acc..last = (acc.last.$1, curr)))
      .map((pair) => pair.$2.difference(pair.$1))
      .toList();

  double _distanceTravelled() => paths()
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.toDouble(), (a, b) => a + b))
      .fold(0.toDouble(), (a, b) => a + b);

  int _incidence() => _timeClusterPrefix().length;

  Duration _timeTravelled() => _timeClusterPrefix().fold(Duration.zero, (a, b) => a + b);
  void updateStatistics() {
    clusterPrefix = _clusterPrefix();
    [
      () => distanceTravelled = _distanceTravelled(),
      () => timeTravelled = _timeTravelled(),
      () => incidence = _incidence(),
      () => areaCount = _areaCount(),
    ].forEach((f) => f());
  }


  num proximity() {
    const num measuredPower = -59;
    final num rssi = dataPoints()
        .sorted((a, b) => a.time.compareTo(b.time))
        .map((e) => e.rssi)
        .toList()
        .smoothedByMovingAverage(5, SmoothingMethod.resizing)
        .last;
    const n = 2;
    return pow(10, (measuredPower - rssi) / (10 * n));
  }

  int _areaCount() {
    int result = 0;

    final Set<LatLng> locations = dataPoints().where((e) => e.location != null).map((e) => e.location!).toSet();
    final Set<(LatLng, LatLng)> locationPairs = {};

    while (locations.isNotEmpty) {
      final LatLng loc = locations.first;
      locations
        ..remove(loc)
        ..forEach((other) {
          distanceBetween(loc, other) <= Settings.shared.distanceThreshold()
              ? locationPairs.add((loc, other))
              : (() {})();
        });
    }

    assert(locations.isEmpty, "Locations should be empty after processing.");

    while (locationPairs.isNotEmpty) {
      result++;
      final (LatLng, LatLng) pair = locationPairs.first;
      final Set<LatLng> locationsToRemove = findThread(locationPairs, {pair.$1, pair.$2});
      locationPairs
        ..remove(pair)
        ..removeWhere((e) => locationsToRemove.contains(e.$1) || locationsToRemove.contains(e.$2));
    }

    assert(locationPairs.isEmpty, "Location pairs should be empty after processing.");

    return result;
  }

  Set<LatLng> findThread(Set<(LatLng, LatLng)> locationPairs, Set<LatLng> locations) {
    final Set<LatLng> locationsToRemove =
        locationPairs.where((e) => locations.contains(e.$1) || locations.contains(e.$2)).fold(
            Set<LatLng>.identity(),
            (acc, e) => acc
              ..add(e.$1)
              ..add(e.$2));
    return locationsToRemove.isEmpty ? locationsToRemove : findThread(locationPairs, locationsToRemove);
  }
}
