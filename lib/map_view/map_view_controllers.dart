part of 'package:bluetooth_detector/map_view/map_view.dart';

extension Controllers on MapViewState {
  static LocationSettings getLocationSettings(int distanceFilter) {
    LocationAccuracy accuracy = LocationAccuracy.high;
    if (Platform.isAndroid) {
      return AndroidSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationText: "Example app will continue to receive your location even when you aren't using it",
              notificationTitle: "Running in Background",
              enableWakeLock: true));
    } else if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
          accuracy: accuracy,
          activityType: ActivityType.fitness,
          distanceFilter: distanceFilter,
          pauseLocationUpdatesAutomatically: true,
          // Only set to true if our app will be started up in the background.
          showBackgroundLocationIndicator: false);
    } else {
      return LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
    }
  }

  void onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = clamp(widget.controller!.zoom + delta, 2, 18);

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  void onScaleStart(ScaleStartDetails details) {
    dragStart = details.focalPoint;
    scaleStart = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - scaleStart;
    scaleStart = details.scale;

    if (scaleDiff > 0) {
      widget.controller!.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      widget.controller!.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - dragStart!;
      dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }
}
