import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

class LatLngTile extends StatelessWidget {
  const LatLngTile(this.coordinate, {super.key});

  final LatLng coordinate;

  Widget CoordinateText(String text) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), child: Text(text));

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Center(
          child: Column(children: [
        CoordinateText("Latitude: ${coordinate.latitude.degrees}"),
        CoordinateText("Longitude: ${coordinate.longitude.degrees}"),
      ])));
}
