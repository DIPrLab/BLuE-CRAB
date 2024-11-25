// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_doubt_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BleDoubtDevice _$BleDoubtDeviceFromJson(Map<String, dynamic> json) => BleDoubtDevice(
      json['address'] as String,
      json['name'] as String,
      json['type'] as String,
      json['id1'] as String,
      json['id2'] as String,
      json['id3'] as String,
      (json['manufacturer'] as num).toInt(),
      (json['parserId'] ?? "") as String,
      json['isSafe'] as bool,
      json['isSuspicious'] as bool,
    );

Map<String, dynamic> _$BleDoubtDeviceToJson(BleDoubtDevice instance) => <String, dynamic>{
      "\"address\"": instance.address,
      "\"name\"": instance.name,
      "\"type\"": instance.type,
      "\"id1\"": instance.id1,
      "\"id2\"": instance.id2,
      "\"id3\"": instance.id3,
      "\"manufacturer\"": instance.manufacturer,
      "\"parserId\"": instance.parserId,
      "\"isSafe\"": instance.isSafe,
      "\"isSuspicious\"": instance.isSuspicious,
    };
