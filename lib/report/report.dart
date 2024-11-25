import 'package:latlng/latlng.dart';
import 'package:bluetooth_detector/report/device/device.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:bluetooth_detector/extensions/stats.dart';
import 'package:bluetooth_detector/ble_doubt_report/ble_doubt_report.dart';

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
  Map<String, Device?> data;

  late Stats timeTravelledStats;
  late Stats incidenceStats;
  late Stats areaStats;
  late Stats distanceTravelledStats;

  Report(this.data);

  void addDevice(Device d) => data[d.id] = d;

  void addDeviceDatum(Device d, LatLng? location, int rssi) => data[d.id]?.addDatum(location, rssi);

  List<Device?> devices() => data.values.toList();
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
