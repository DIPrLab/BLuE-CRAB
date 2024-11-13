part of 'package:bluetooth_detector/scanner_view/scanner_view.dart';

extension Scanner on ScannerViewState {
  void dispose() => scanResultsSubscription
      .cancel()
      .then((_) => isScanningSubscription.cancel().then((_) => disableLocationStream()));

  // android is slow when asking for all advertisements,
  // so instead we only ask for 1/8 of them
  Future startScan() async => FlutterBluePlus.startScan(
          continuousUpdates: true, removeIfGone: Duration(seconds: 1), continuousDivisor: Platform.isAndroid ? 8 : 1)
      .then((_) => widget.settings.locationEnabled ? enableLocationStream() : disableLocationStream());

  Future stopScan() async => FlutterBluePlus.stopScan().then((_) => disableLocationStream());

  void probe(BluetoothDevice device) async {
    if (widget.settings.autoConnect) {
      await device.connect(autoConnect: device.isAutoConnectEnabled);
      await device.discoverServices();
    }
  }
}
