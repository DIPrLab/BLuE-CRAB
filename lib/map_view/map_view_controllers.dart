part of 'map_view.dart';

extension Controllers on MapViewState {
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
              pauseLocationUpdatesAutomatically: true,
              // Only set to true if our app will be started up in the background.
              showBackgroundLocationIndicator: false)
          : LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilter);

  void onDoubleTap(MapTransformer transformer, Offset position) =>
      setState(() => transformer.setZoomInPlace(clamp(widget.controller.zoom + 0.5, 2, 18), position));

  void onScaleStart(ScaleStartDetails details) {
    dragStart = details.focalPoint;
    scaleStart = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - scaleStart;
    scaleStart = details.scale;

    if (scaleDiff > 0) {
      setState(() => widget.controller.zoom += 0.02);
    } else if (scaleDiff < 0) {
      setState(() => widget.controller.zoom -= 0.02);
    } else {
      final now = details.focalPoint;
      final diff = now - dragStart!;
      dragStart = now;
      setState(() => transformer.drag(diff.dx, diff.dy));
    }
  }
}
