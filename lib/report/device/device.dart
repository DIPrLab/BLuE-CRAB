import 'package:collection/collection.dart';
import 'package:latlng/latlng.dart';
import 'package:bluetooth_detector/report/datum.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/extensions/geolocator.dart';
import 'package:bluetooth_detector/extensions/ordered_pairs.dart';
import 'package:bluetooth_detector/assigned_numbers/company_identifiers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bluetooth_detector/extensions/collections.dart';

part 'device.g.dart';

/// Device data type
///
/// This type is used to pair details of Bluetooth Devices
/// along with metadata that goes along with it
@JsonSerializable()
class Device {
  String id;
  String name;
  String platformName;
  List<int> manufacturer;
  Set<Datum> _dataPoints = {};
  Device(this.id, this.name, this.platformName, this.manufacturer);
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  Set<Datum> dataPoints(Duration windowDuration) =>
      _dataPoints.where((datum) => datum.time.isAfter(DateTime.now().subtract(windowDuration))).toSet();

  void addLocation(LatLng? location) => _dataPoints.add(Datum(location));

  String deviceLabel() => !this.name.isEmpty
      ? this.name
      : !this.platformName.isEmpty
          ? this.platformName
          : !this.manufacturer.isEmpty
              ? this.manufacturers().join(", ")
              : this.id;

  Iterable<String> manufacturers() =>
      manufacturer.map((e) => company_identifiers[e.toRadixString(16).toUpperCase().padLeft(4, "0")] ?? "Unknown");

  Set<LatLng> locations(Duration windowDuration) => this
      .dataPoints(windowDuration)
      .where((dataPoint) => dataPoint.location != null)
      .map((dataPoint) => dataPoint.location!)
      .toSet();

  int incidence(Duration thresholdTime, Duration windowDuration) =>
      this
          .dataPoints(windowDuration)
          .map((datum) => datum.time)
          .sorted((a, b) => a.compareTo(b))
          .orderedPairs()
          .map((pair) => pair.$2.difference(pair.$1))
          .where((duration) => duration > thresholdTime)
          .length +
      1;

  Set<Area> areas(double thresholdDistance, Duration windowDuration) {
    Set<Area> result = {};
    locations(windowDuration).forEach((location) => result
        .where((area) => area.any((areaLocation) => distanceBetween(location, areaLocation) < thresholdDistance))
        .forEach((area) => area.add(location)));
    return result.combineSetsWithCommonElements();
  }

  Duration timeTravelled(Duration thresholdTime, Duration windowDuration) => this
      .dataPoints(windowDuration)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .where((duration) => duration < thresholdTime)
      .fold(Duration(), (a, b) => a + b);

  List<Path> paths(Duration thresholdTime, Duration windowDuration) {
    List<Path> paths = <Path>[];
    List<PathComponent> dataPoints = this
        .dataPoints(windowDuration)
        .where((dataPoint) => dataPoint.location != null)
        .map((datum) => PathComponent(datum.time, datum.location!))
        .sorted((a, b) => a.time.compareTo(b.time));

    while (!dataPoints.isEmpty) {
      PathComponent curr = dataPoints.first;
      dataPoints.removeAt(0);
      DateTime time1 = paths.isEmpty ? DateTime(1970) : paths.last.last.time;
      DateTime time2 = curr.time;
      Duration time = time2.difference(time1);
      if (time < thresholdTime) {
        paths.last.add(curr);
      } else {
        paths.add([curr]);
      }
    }

    return paths;
  }

  double distanceTravelled(Duration thresholdTime, Duration windowDuration) => paths(thresholdTime, windowDuration)
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);
}
