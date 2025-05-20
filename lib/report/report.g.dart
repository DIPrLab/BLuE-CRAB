// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) {
  Report? report;
  try {
    report = Report(
        (json['data'] as Map<String, dynamic>).map((k, e) => MapEntry(k, Device.fromJson(e as Map<String, dynamic>))))
      ..time = DateTime.parse(json['time'] as String);
  } catch (e) {
    Logger().w("Failed to load report as Report");
    try {
      report = BleDoubtReport.fromJson(json).toReport();
    } catch (e) {
      Logger().w("Failed to load report as BleDoubtReport");
      Logger().i("Generating empty report");
    }
  }
  return report ?? Report({});
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      '"time"': '"${instance.time.toIso8601String()}"',
      '"data"': instance.data.map((a, b) => MapEntry('"$a"', "${b.toJson()}")),
    };
