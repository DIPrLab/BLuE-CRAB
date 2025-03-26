// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_doubt_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BleDoubtReport _$BleDoubtReportFromJson(Map<String, dynamic> json) => BleDoubtReport(
      (json['devices'] as List<dynamic>).map((e) => BleDoubtDevice.fromJson(e as Map<String, dynamic>)).toList(),
      (json['detections'] as List<dynamic>).map((e) => BleDoubtDetection.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$BleDoubtReportToJson(BleDoubtReport instance) => <String, dynamic>{
      '"devices"': instance.devices,
      '"detections"': instance.detections,
    };
