import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

extension toJSON on Position {
  LatLng toLatLng() => LatLng.degree(latitude, longitude);
}
