import 'dart:math';
import 'package:latlng/latlng.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:bluetooth_detector/extensions/stats.dart';

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

  List<Device?> devices() => data.values.toList();
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
