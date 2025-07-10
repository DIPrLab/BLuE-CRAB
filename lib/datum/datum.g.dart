// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng? fromString(String latlng) {
  try {
    final List<double> components = latlng.split(",").map((x) {
      assert(x.toDouble() is! Error, "");
      return x.toDouble();
    }).toList();
    return components.length == 2 ? LatLng.degree(components[0], components[1]) : null;
  } catch (e) {
    return null;
  }
}

Datum _$DatumFromJson(Map<String, dynamic> json) =>
    Datum(fromString(json['l'] ?? "" as String?), int.parse(json['r']))..time = DateTime.parse(json['t'] as String);

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      '"l"': '"${instance.location?.latitude.degrees},${instance.location?.longitude.degrees}"',
      '"r"': '"${instance.rssi}"',
      '"t"': '"${instance.time.toIso8601String()}"',
    };
