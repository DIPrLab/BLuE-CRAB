import 'package:bluetooth_detector/map_view/position.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

/// Determine the current position of the device.
Future<LatLng> getLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  Position position = await Geolocator.getCurrentPosition();
  return position.toLatLng();
}

LatLng middlePoint(List<LatLng> locations) {
  if (locations.isEmpty) {
    return LatLng.degree(0.0, 0.0);
  }
  List<double> latitudes = [];
  List<double> longitudes = [];
  for (var location in locations) {
    latitudes.insert(0, location.latitude.degrees);
    longitudes.insert(0, location.longitude.degrees);
  }
  double latitude = (latitudes.max + latitudes.min) / 2;
  double longitude = (longitudes.max + longitudes.min) / 2;
  return LatLng.degree(latitude, longitude);
}
