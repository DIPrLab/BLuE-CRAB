// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) {
  Report? report = null;
  try {
    report = Report((json['data'] as Map<String, dynamic>)
        .map((k, e) => MapEntry(k, e == null ? null : Device.fromJson(e as Map<String, dynamic>))))
      ..time = DateTime.parse(json['time'] as String);
  } catch (e) {
    try {
      report = BleDoubtReport.fromJson(json).toReport();
    } catch (e) {}
  }
  return report ?? Report({});
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      "\"time\"": "\"${instance.time.toIso8601String()}\"",
      "\"data\"": instance._data.map((a, b) => MapEntry("\"${a}\"", "${b?.toJson() ?? ""}")),
    };
