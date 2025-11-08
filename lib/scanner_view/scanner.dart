part of 'scanner_view.dart';

extension Scanner on ScannerViewState {
  void dispose() => scanResultsSubscription
      .cancel()
      .then((_) => isScanningSubscription.cancel().then((_) => disableLocationStream()));

  void handleScannedData(List<ScanResult> results) {
    results
        .map((sr) => (
              Device(sr.device.remoteId.toString(), sr.advertisementData.advName, sr.device.platformName,
                  sr.advertisementData.manufacturerData.keys.toList(),
                  t: sr.advertisementData.txPowerLevel),
              sr.rssi
            ))
        .forEach((d) => report.addDatumToDevice(d.$1, location, d.$2));
    if (Settings.shared.autoConnect) {
      results.where((d) => d.advertisementData.connectable).forEach((result) => probe(result.device));
    }
    if (Settings.shared.demoMode) {
      deviceCount = report.devices().length;
      datapointCount = report.devices().map((d) => d.dataPoints().length).fold(0, (a, b) => a + b);
    }
    if (mounted) {
      setState(() {});
    }
  }

  // android is slow when asking for all advertisements,
  // so instead we only ask for 1/8 of them
  Future<void> startScan() async => FlutterBluePlus.startScan(
          continuousUpdates: true,
          removeIfGone: const Duration(seconds: 1),
          continuousDivisor: Platform.isAndroid ? 8 : 1)
      .then((_) => Settings.shared.locationEnabled ? enableLocationStream() : disableLocationStream());

  Future<void> stopScan() async => FlutterBluePlus.stopScan().then((_) => disableLocationStream());

  void probe(BluetoothDevice device) =>
      device.connect(autoConnect: device.isAutoConnectEnabled).then((_) => device.discoverServices());
}
