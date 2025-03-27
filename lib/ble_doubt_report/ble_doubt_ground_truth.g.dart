// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_doubt_ground_truth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BleDoubtGroundTruth _$BleDoubtGroundTruthFromJson(Map<String, dynamic> json) =>
    BleDoubtGroundTruth((json["gt"] as Map<String, dynamic>)
        .map((k, e) => MapEntry(k, (e as Set<dynamic>).map((e) => e as String).toSet())));

Map<String, dynamic> _$BleDoubtGroundTruthToJson(BleDoubtGroundTruth instance) => <String, dynamic>{"gt": instance.gt};
