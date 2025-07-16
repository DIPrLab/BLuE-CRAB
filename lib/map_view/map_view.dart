import 'dart:io';
import 'dart:math';

import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/map_view/build_marker_widget.dart';
import 'package:blue_crab/map_view/tile_servers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

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
  double currentZoom = 0;
  @override
  void initState() {
    super.initState();
    currentZoom = widget.controller.zoom;
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
                      setState(() {
                        transformer.setZoomInPlace(widget.controller.zoom, event.localPosition);
                        currentZoom = widget.controller.zoom;
                      });
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
                    CustomPaint(painter: PolylinePainter(transformer, widget.device, currentZoom)),
                    ...widget.device
                        .paths()
                        .map((e) => e.first == e.last ? {e.first} : {e.first, e.last})
                        .expand((e) => e)
                        .map((pc) => buildMarkerWidget(context,transformer.toOffset(pc.location),
                            Icon(Icons.circle,color: Colors.red, size: ((5 * pow(2, currentZoom - 15)) as double).clamp(8.0, 24.0),),
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

  static LocationSettings getLocationSettings(int distanceFilter) => Platform.isAndroid
      ? AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationText: "BL(u)E CRAB will continue to receive your location even when you aren't using it",
              notificationTitle: "Running in Background",
              enableWakeLock: true))
      : Platform.isIOS || Platform.isMacOS
          ? AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.fitness,
              distanceFilter: distanceFilter,
              pauseLocationUpdatesAutomatically: true)
          : LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilter);

  void onDoubleTap(MapTransformer transformer, Offset position) {
    setState(() {
      currentZoom = widget.controller.zoom;
      transformer.setZoomInPlace(widget.controller.zoom, position);
    });
  }

  void onScaleStart(ScaleStartDetails details) {
    dragStart = details.focalPoint;
    scaleStart = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - scaleStart;
    scaleStart = details.scale;

    if (scaleDiff > 0) {
      setState(() => widget.controller.zoom += 0.02);
      currentZoom = widget.controller.zoom;
    } else if (scaleDiff < 0) {
      setState(() {
        widget.controller.zoom -= 0.02;
        currentZoom = widget.controller.zoom;
      });
    } else {
      final now = details.focalPoint;
      final diff = now - dragStart!;
      dragStart = now;
      setState(() => transformer.drag(diff.dx, diff.dy));
      currentZoom = widget.controller.zoom;
    }
  }
}

class PolylinePainter extends CustomPainter {
  PolylinePainter(this.transformer, this.device, this.currentZoom);

  final Device device;
  final MapTransformer transformer;
  final double currentZoom;

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
                    ..strokeWidth = (1 * pow(currentZoom - 15, 2)).toDouble().clamp(1.5, 4.0),
                ));
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
