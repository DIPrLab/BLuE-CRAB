// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      json['id'] as String,
      name: json['name'] as String? ?? "",
      platformName: json['platformName'] as String? ?? "",
      manufacturer: (json['manufacturer'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      dataPoints:
          (json['dataPoints'] as List<dynamic>?)?.map((e) => Datum.fromJson(e as Map<String, dynamic>)).toSet() ??
              const {},
      markedSafe: json['markedSafe'] as bool? ?? false,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      "\"id\"": "\"${instance.id}\"",
      "\"name\"": "\"${instance.name}\"",
      "\"platformName\"": "\"${instance.platformName}\"",
      "\"markedSafe\"": instance.markedSafe,
      "\"manufacturer\"": instance.manufacturer,
      "\"dataPoints\"": instance.dataPoints.map((datum) => "${datum.toJson()}").toList(),
    };
