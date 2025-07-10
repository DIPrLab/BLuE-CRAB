import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/device/device.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';
import 'package:statistics/statistics.dart';

part 'compact_dataset.g.dart';

@JsonSerializable()
class CompactDataset {
  CompactDataset(this.devices, this.locationHistory);
  factory CompactDataset.fromJson(Map<String, dynamic> json) => _$CompactDatasetFromJson(json);
  Map<String, dynamic> toJson() => _$CompactDatasetToJson(this);

  Map<String, (String, String, List<int>, Map<DateTime, List<int>>)> devices;
  Map<DateTime, (double, double)?> locationHistory;

  LatLng? toLatLng((double, double)? location) => location == null ? null : LatLng.degree(location.$1, location.$2);
  LatLng? getLocationAtTime(DateTime t) => toLatLng(
      locationHistory.entries.where((e) => e.key.isBefore(t)).sorted((a, b) => a.key.compareTo(b.key)).last.value);

  Report toReport() => Report(devices.entries
      .map((e) => MapEntry(
          e.key,
          Device(e.key, e.value.$1, e.value.$2, e.value.$3,
              dataPoints: e.value.$4.entries
                  .map((e) => Datum(getLocationAtTime(e.key), e.value.average.round())..time = e.key)
                  .toSet())))
      .toMap((e) => e.key, (e) => e.value));
}
