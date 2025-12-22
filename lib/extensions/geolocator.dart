import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

double distanceBetween(LatLng a, LatLng b) =>
    Geolocator.distanceBetween(a.latitude.degrees, a.longitude.degrees, b.latitude.degrees, b.longitude.degrees);

extension DistanceBetween on LatLng {
  double distanceTo(LatLng other) => distanceBetween(this, other);
}
