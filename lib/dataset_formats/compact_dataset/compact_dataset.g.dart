// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compact_dataset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompactDataset _$CompactDatasetFromJson(Map<String, dynamic> json) => CompactDataset(
      (json['devices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            _$recordConvert(
              e,
              ($jsonValue) => (
                $jsonValue[r'$1'] as String,
                $jsonValue[r'$2'] as String,
                ($jsonValue[r'$3'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
                ($jsonValue[r'$4'] as Map<String, dynamic>).map(
                  (k, e) => MapEntry(DateTime.parse(k), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
                ),
                ($jsonValue[r'$5'] as num?)?.toInt(),
              ),
            )),
      ),
      (json['locationHistory'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            DateTime.parse(k),
            _$recordConvertNullable(
              e,
              ($jsonValue) => (
                ($jsonValue[r'$1'] as num).toDouble(),
                ($jsonValue[r'$2'] as num).toDouble(),
              ),
            )),
      ),
    );

Map<String, dynamic> _$CompactDatasetToJson(CompactDataset instance) => <String, dynamic>{
      'devices': instance.devices.map((k, e) => MapEntry(k, <String, dynamic>{
            r'"$1"': '"${e.$1}"',
            r'"$2"': '"${e.$2}"',
            r'"$3"': '"${e.$3}"',
            r'"$4"': e.$4.map((k, e) => MapEntry('"${k.toIso8601String()}"', e)),
            r'"$5"': '"${e.$5}"',
          })),
      '"locationHistory"': instance.locationHistory.map((k, e) => MapEntry(
          '"${k.toIso8601String()}"',
          e == null
              ? null
              : <String, dynamic>{
                  r'"$1"': e!.$1,
                  r'"$2"': e!.$2,
                })),
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

$Rec? _$recordConvertNullable<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    value == null ? null : convert(value as Map<String, dynamic>);
