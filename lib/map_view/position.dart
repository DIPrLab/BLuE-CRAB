import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

extension ToJSON on Position {
  LatLng toLatLng() => LatLng.degree(latitude, longitude);
}
