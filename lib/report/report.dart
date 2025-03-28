import 'package:blue_crab/ble_doubt_report/ble_doubt_report.dart';
import 'package:blue_crab/extensions/stats.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/settings.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

part 'report.g.dart';
part 'report_cache.dart';
part 'report_stats.dart';
part 'synthetic_report.dart';

typedef Area = Set<LatLng>;
typedef Path = List<PathComponent>;

class PathComponent {
  PathComponent(this.time, this.location);
  DateTime time;
  LatLng location;
}

@JsonSerializable()
class Report {
  Report(this.data);
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  DateTime time = DateTime.now();
  Map<String, Device> data;

  late Stats timeTravelledStats;
  late Stats incidenceStats;
  late Stats areaStats;
  late Stats distanceTravelledStats;
  late Stats riskScoreStats;
  DateTime lastUpdated = DateTime(0);
  Set<String> riskyDevices = {};

  Device? getDevice(String id) => data[id];
  void addDevice(Device d) {
    if (!data.keys.contains(d.id)) {
      data[d.id] = d;
    }
  }

  void addDatumToDevice(Device d, LatLng? location, int rssi) {
    addDevice(d);
    data[d.id]?.addDatum(location, rssi);
  }

  void combine(Report report) =>
      report.data.forEach((id, d) => data.update(id, (device) => device..combine(d), ifAbsent: () => d));

  List<DateTime> getTimestamps() => devices()
      .map((d) => d.dataPoints(testing: true).map((d) => d.time).toSet())
      .fold(<DateTime>{}, (a, b) => a..addAll(b)).toList()
    ..sort();

  Set<Device> getSuspiciousDevices() => Settings.shared.classifier.getRiskyDevices(this);
  Set<String> getSuspiciousDeviceIDs() => Settings.shared.classifier.getRiskyDeviceIDs(this);

  Set<Device> devices() => data.values.toSet();
  Set<String> deviceIDs() => data.values.map((d) => d.id).toSet();
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
