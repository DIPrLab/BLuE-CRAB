part of 'scanner_view.dart';

extension Scanner on ScannerViewState {
  void dispose() => scanResultsSubscription
      .cancel()
      .then((_) => isScanningSubscription.cancel().then((_) => disableLocationStream()));

  // android is slow when asking for all advertisements,
  // so instead we only ask for 1/8 of them
  Future<void> startScan() async => FlutterBluePlus.startScan(
          continuousUpdates: true, removeIfGone: Duration(seconds: 1), continuousDivisor: Platform.isAndroid ? 8 : 1)
      .then((_) => Settings.shared.locationEnabled ? enableLocationStream() : disableLocationStream());

  Future<void> stopScan() async => FlutterBluePlus.stopScan().then((_) => disableLocationStream());

  void probe(BluetoothDevice device) =>
      device.connect(autoConnect: device.isAutoConnectEnabled).then((_) => device.discoverServices());
}
