import 'package:json_annotation/json_annotation.dart';

part 'ble_doubt_ground_truth.g.dart';

@JsonSerializable()
class BleDoubtGroundTruth {
  BleDoubtGroundTruth(this.gt);
  factory BleDoubtGroundTruth.fromJson(Map<String, dynamic> json) => _$BleDoubtGroundTruthFromJson(json);
  Map<String, Set<String>> gt;
  Map<String, dynamic> toJson() => _$BleDoubtGroundTruthToJson(this);
}
