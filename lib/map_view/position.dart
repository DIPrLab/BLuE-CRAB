import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

extension toJSON on Position {
  LatLng toLatLng() {
    return LatLng.degree(this.latitude, this.longitude);
  }
}
