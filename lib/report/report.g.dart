// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) {
  Report? report = null;
  try {
    Report((json['data'] as Map<String, dynamic>)
        .map((k, e) => MapEntry(k, e == null ? null : Device.fromJson(e as Map<String, dynamic>))))
      ..time = DateTime.parse(json['time'] as String);
  } catch (e) {}
  try {
    List<Device> devices =
        (json['devices'] as List<dynamic>).map((e) => Device("id", "name", "platformName", [])).toList();
    Report((json['data'] as Map<String, dynamic>)
        .map((k, e) => MapEntry(k, e == null ? null : Device.fromJson(e as Map<String, dynamic>))))
      ..time = DateTime.parse(json['time'] as String);
  } catch (e) {}
  return report!;
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      "\"time\"": "\"${instance.time.toIso8601String()}\"",
      "\"data\"": instance.data.map((a, b) => MapEntry("\"${a}\"", "${b?.toJson() ?? ""}")),
    };
