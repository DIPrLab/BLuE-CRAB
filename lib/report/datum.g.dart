// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng? fromString(String latlng) {
  final List<double> components = latlng.split(",").map((x) {
    assert(x.toDouble() is! Error);
    return x.toDouble();
  }).toList();
  return components.length == 2 ? LatLng.degree(components[0], components[1]) : null;
}

Datum _$DatumFromJson(Map<String, dynamic> json) =>
    Datum(fromString(json['location'] ?? "" as String?), int.parse(json['rssi']))
      ..time = DateTime.parse(json['time'] as String);

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      "\"location\"": "\"${instance.location?.latitude.degrees},${instance.location?.longitude.degrees}\"",
      "\"rssi\"": "\"${instance.rssi}\"",
      "\"time\"": "\"${instance.time.toIso8601String()}\"",
    };
