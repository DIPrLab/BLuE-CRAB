// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(json['id'] as String, json['name'] as String,
    json['platformName'] as String, (json['manufacturer'] as List<dynamic>).map((e) => (e as num).toInt()).toList())
  ..isTrusted = json['isTrusted'] as bool
  .._dataPoints = (json['_dataPoints'] as List<dynamic>).map((e) => Datum.fromJson(e as Map<String, dynamic>)).toSet();

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      "\"id\"": "\"${instance.id}\"",
      "\"name\"": "\"${instance.name}\"",
      "\"platformName\"": "\"${instance.platformName}\"",
      "\"manufacturer\"": instance.manufacturer,
      "\"isTrusted\"": instance.isTrusted,
      "\"_dataPoints\"": instance._dataPoints.map((datum) => "${datum.toJson()}").toList(),
    };
