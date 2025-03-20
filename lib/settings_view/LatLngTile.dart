import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

class LatLngTile extends StatelessWidget {
  const LatLngTile(this.coordinate, {super.key});

  final LatLng coordinate;

  Widget CoordinateText(String text) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), child: Text(text));

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Center(
          child: Column(children: [
        CoordinateText("Latitude: ${coordinate.latitude.degrees}"),
        CoordinateText("Longitude: ${coordinate.longitude.degrees}"),
      ])));
}
