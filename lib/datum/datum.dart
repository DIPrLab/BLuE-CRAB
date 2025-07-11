import 'package:blue_crab/extensions/date_time.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

/// Datum used to generate Data
@JsonSerializable()
class Datum {
  Datum(this.location, this.rssi) {
    time = DateTime.now().roundedToSecond();
  }
  LatLng? location;
  int rssi;
  late DateTime time;
}
