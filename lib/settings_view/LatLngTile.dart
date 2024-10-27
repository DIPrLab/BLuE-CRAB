import 'package:latlng/latlng.dart';
import 'package:flutter/material.dart';

class LatLngTile extends StatelessWidget {
  LatLngTile(LatLng this.coordinate, {super.key});

  final LatLng coordinate;

  Widget CoordinateText(String text) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Center(
            child: Column(
          children: [
            CoordinateText(
                "Latitude: " + coordinate.latitude.degrees.toString()),
            CoordinateText(
                "Longitude: " + coordinate.longitude.degrees.toString()),
          ],
        )));
  }
}
