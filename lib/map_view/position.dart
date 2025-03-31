import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

extension ToJson on Position {
  LatLng toLatLng() => LatLng.degree(latitude, longitude);
}
