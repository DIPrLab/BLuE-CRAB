import 'package:collection/collection.dart';
import 'package:latlng/latlng.dart';
import 'package:bluetooth_detector/report/datum.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/extensions/geolocator.dart';
import 'package:bluetooth_detector/extensions/ordered_pairs.dart';
import 'package:bluetooth_detector/assigned_numbers/company_identifiers.dart';
import 'package:json_annotation/json_annotation.dart';

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
  Set<Datum> dataPoints = {};
  Device(this.id, this.name, this.platformName, this.manufacturer);
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  Iterable<String> manufacturers() =>
      manufacturer.map((e) => company_identifiers[e.toRadixString(16).toUpperCase().padLeft(4, "0")] ?? "Unknown");

  Set<LatLng> locations() =>
      this.dataPoints.where((dataPoint) => dataPoint.location != null).map((dataPoint) => dataPoint.location!).toSet();

  int incidence(int thresholdTime) =>
      this
          .dataPoints
          .map((datum) => datum.time)
          .sorted((a, b) => a.compareTo(b))
          .orderedPairs()
          .map((pair) => pair.$2.difference(pair.$1))
          .where((duration) => duration > (Duration(seconds: thresholdTime)))
          .length +
      1;

  Set<Area> areas(double thresholdDistance) {
    Set<Area> result = {};
    for (LatLng curr in locations()) {
      if (result.isEmpty) {
        result.add({curr});
        continue;
      }
      for (Area area in result) {
        for (LatLng location in area) {
          double distance = distanceBetween(curr, location);
          if (distance <= thresholdDistance) {
            area.add(curr);
            break;
          }
        }
      }
    }
    for (Area area1 in result) {
      for (Area area2 in result.difference({area1})) {
        if (area1.intersection(area2).isNotEmpty) {
          area1 = area1.union(area2);
          result.remove(area2);
        }
      }
    }
    return result;
  }

  Duration timeTravelled(int thresholdTime) => this
      .dataPoints
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .fold(Duration(), (a, b) => b < Duration(seconds: thresholdTime) ? a + b : a);

  List<Path> paths(int thresholdTime) {
    List<Path> paths = <Path>[];
    List<PathComponent> dataPoints = this.dataPoints.where((dataPoint) => dataPoint.location != null).map((datum) {
      LatLng location = datum.location!;
      return PathComponent(datum.time, location);
    }).sorted((a, b) => a.time.compareTo(b.time));

    while (!dataPoints.isEmpty) {
      PathComponent curr = dataPoints.first;
      dataPoints.removeAt(0);
      if (paths.isEmpty) {
        paths.add([curr]);
      } else {
        DateTime time1 = paths.last.last.time;
        DateTime time2 = curr.time;
        Duration time = time2.difference(time1);
        if (time < Duration(seconds: thresholdTime)) {
          paths.last.add(curr);
        } else {
          paths.add([curr]);
        }
      }
    }

    return paths;
  }

  double distanceTravelled(int thresholdTime) => paths(thresholdTime)
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);
}
