import 'package:latlng/latlng.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/extensions/stats.dart';
import 'package:blue_crab/ble_doubt_report/ble_doubt_report.dart';

part 'report.g.dart';
part 'report_cache.dart';
part 'report_stats.dart';

typedef Area = Set<LatLng>;
typedef Path = List<PathComponent>;

class PathComponent {
  DateTime time;
  LatLng location;

  PathComponent(this.time, this.location);
}

@JsonSerializable()
class Report {
  DateTime time = DateTime.now();
  Map<String, Device> data;

  late Stats timeTravelledStats;
  late Stats incidenceStats;
  late Stats areaStats;
  late Stats distanceTravelledStats;
  late Stats riskScoreStats;
  DateTime lastUpdated = DateTime(0);

  Report(this.data);

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

  List<Device> devices() => data.values.toList();
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
