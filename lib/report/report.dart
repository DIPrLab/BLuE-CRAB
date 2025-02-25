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
  Map<String, Device> _data;

  late Stats timeTravelledStats;
  late Stats incidenceStats;
  late Stats areaStats;
  late Stats distanceTravelledStats;
  late Stats riskScoreStats;
  DateTime lastUpdated = DateTime(0);

  Report(this._data);

  Device? getDevice(String id) => _data[id];
  void addDevice(Device d) => _data.keys.contains(d.id) ? null : _data[d.id] = d;
  void addDatumToDevice(Device d, LatLng? location, int rssi) {
    addDevice(d);
    _data[d.id]?.addDatum(location, rssi);
  }

  void combine(Report report) =>
      report._data.forEach((id, d) => _data.update(id, (device) => device..combine(d), ifAbsent: () => d));

  List<Device> devices() => _data.values.toList();
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
