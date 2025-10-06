part of 'device.dart';

extension DeviceStats on Device {
  void updateStatistics() {
    clusterPrefix = _clusterPrefix();
    [
      () => distanceTravelled = _distanceTravelled(),
      () => timeTravelled = _timeTravelled(),
      () => incidence = _incidence(),
      () => areaCount = _areaCount(),
    ].forEach((f) => f());
  }

  List<List<(Datum, Datum)>> _clusterPrefix() => dataPoints()
          .orderedPairs()
          .where((e) => e.$2.time.difference(e.$1.time) <= Settings.shared.timeThreshold())
          .fold(List<List<(Datum, Datum)>>.empty(growable: true), (acc, e) {
        if (acc.isEmpty) {
          acc.add([e]);
        } else if (acc.last.last.$2 == e.$1) {
          acc.last.add(e);
        } else {
          acc.add([e]);
        }
        return acc;
      });

  double _distanceTravelled() => clusterPrefix
      .fold(List<(Datum, Datum)>.empty(), (acc, e) => acc + e)
      .where((e) => e.$1.location != null && e.$2.location != null)
      .map((e) => distanceBetween(e.$1.location!, e.$2.location!))
      .fold(0.toDouble(), (acc, e) => acc + e);

  int _incidence() => clusterPrefix.length;

  Duration _timeTravelled() =>
      clusterPrefix.map((e) => e.last.$2.time.difference(e.first.$1.time)).fold(Duration.zero, (a, b) => a + b);

  num proximity() {
    const num measuredPower = -59;
    final num rssi = dataPoints().map((e) => e.rssi).toList().smoothedByMovingAverage(5, SmoothingMethod.resizing).last;
    const n = 2;
    return pow(10, (measuredPower - rssi) / (10 * n));
  }

  int _areaCount() {
    return 1;
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
    return locationsToRemove.isEmpty ? locationsToRemove : locationsToRemove
      ..addAll(findThread(locationPairs, locationsToRemove));
  }
}
