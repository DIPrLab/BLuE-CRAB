// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_doubt_detection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

String parse(String input) {
  List<String> date = input
      .split(" ")
      .map((str) {
        if (str == "Jan") {
          return "01";
        } else if (str == "Feb") {
          return "02";
        } else if (str == "Mar") {
          return "03";
        } else if (str == "Apr") {
          return "04";
        } else if (str == "May") {
          return "05";
        } else if (str == "Jun") {
          return "06";
        } else if (str == "Jul") {
          return "07";
        } else if (str == "Aug") {
          return "08";
        } else if (str == "Sep") {
          return "09";
        } else if (str == "Oct") {
          return "10";
        } else if (str == "Nov") {
          return "11";
        } else if (str == "Dec") {
          return "12";
        }
        return str;
      })
      .map((str) => str.padLeft(2, "0"))
      .toList();
  List<String> time = date[3].split(":").map((str) => str.padLeft(2, "0")).toList();
  date.removeAt(4);
  date.removeAt(3);
  date.removeAt(0);
  date.insert(0, date[2]);
  date.removeAt(3);

  String result = date.join("-") + " " + time.join(":");

  return result;
}

BleDoubtDetection _$BleDoubtDetectionFromJson(Map<String, dynamic> json) => BleDoubtDetection(
      (json['lat'] as num).toDouble(),
      (json['long'] as num).toDouble(),
      json['mac'] as String,
      (json['rssi'] as num).toInt(),
      DateTime.parse(parse(json['t'] as String)),
    );

Map<String, dynamic> _$BleDoubtDetectionToJson(BleDoubtDetection instance) => <String, dynamic>{
      "\"lat\"": instance.lat,
      "\"long\"": instance.long,
      "\"mac\"": instance.mac,
      "\"rssi\"": instance.rssi,
      "\"t\"": instance.t.toIso8601String(),
    };
