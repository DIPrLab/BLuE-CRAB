import 'dart:io';
import 'dart:math';

import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/map_view/build_marker_widget.dart';
import 'package:blue_crab/map_view/tile_servers.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

part 'map_view_controllers.dart';

class MapView extends StatefulWidget {
  const MapView(this.device, this.controller, {super.key});

  final Device device;
  final MapController controller;

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Offset? dragStart;
  double scaleStart = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: MapLayout(
          controller: widget.controller,
          builder: (context, transformer) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (details) => onDoubleTap(transformer, details.localPosition),
              onScaleStart: onScaleStart,
              onScaleUpdate: (details) => onScaleUpdate(details, transformer),
              child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      setState(() => transformer.setZoomInPlace(
                          (widget.controller.zoom + event.scrollDelta.dy / -1000.0).clamp(2, 18), event.localPosition));
                    }
                  },
                  child: Stack(children: [
                    TileLayer(builder: (context, x, y, z) {
                      final tilesInZoom = pow(2.0, z).floor();

                      while (x < 0) {
                        x += tilesInZoom;
                      }
                      while (y < 0) {
                        y += tilesInZoom;
                      }

                      x %= tilesInZoom;
                      y %= tilesInZoom;

                      return CachedNetworkImage(imageUrl: mapbox(z, x, y), fit: BoxFit.cover);
                    }),
                    CustomPaint(painter: PolylinePainter(transformer, widget.device)),
                    ...widget.device
                        .paths()
                        .map((e) => e.first == e.last ? {e.first} : {e.first, e.last})
                        .expand((e) => e)
                        .map((pc) => buildMarkerWidget(context, transformer.toOffset(pc.location),
                            const Icon(Icons.circle, color: Colors.red, size: 24),
                            backgroundCircle: false,
                            alertContent: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text("Location: (${[
                                pc.location.latitude.degrees,
                                pc.location.longitude.degrees
                              ].join(", ")})"),
                              Text("Date: ${[pc.time.month, pc.time.day, pc.time.year].join("/")}"),
                              Text("Time: ${[pc.time.hour, pc.time.minute, pc.time.second].join(":")}")
                            ])))
                        .toList(),
                  ])))));
}

class PolylinePainter extends CustomPainter {
  PolylinePainter(this.transformer, this.device);

  Device device;
  final MapTransformer transformer;

  Offset generateOffsetPosition(Position p) => transformer.toOffset(LatLng.degree(p.latitude, p.longitude));

  Offset generateOffsetLatLng(LatLng coordinate) => transformer.toOffset(coordinate);

  @override
  void paint(Canvas canvas, Size size) => device.paths().forEach((path) {
        path.forEachMappedOrderedPair(
            (pc) => generateOffsetLatLng(pc.location),
            (offsets) => canvas.drawLine(
                offsets.$1,
                offsets.$2,
                Paint()
                  ..color = Colors.red
                  ..strokeWidth = 4));
      });

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(PolylinePainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(PolylinePainter oldDelegate) => false;
}
