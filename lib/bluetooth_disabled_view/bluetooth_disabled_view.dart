import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// import 'package:blue_crab/utils/snackbar.dart';

class BluetoothOffView extends StatelessWidget {
  const BluetoothOffView({super.key, this.adapterState});

  final BluetoothAdapterState? adapterState;

  Widget bluetoothOffIcon(BuildContext context) => const Icon(Icons.bluetooth_disabled, size: 200);

  Widget errorText(BuildContext context) =>
      Text('Bluetooth Adapter is ${adapterState?.toString().split(".").last ?? 'not available'}');

  Widget turnOnBluetoothButton(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          child: const Text('TURN ON'),
          onPressed: () async {
            await FlutterBluePlus.turnOn();
          }));

  @override
  Widget build(BuildContext context) => ScaffoldMessenger(
          // key: Snackbar.snackBarKeyA,
          child: Scaffold(
              body: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
        bluetoothOffIcon(context),
        errorText(context),
        if (Platform.isAndroid) turnOnBluetoothButton(context),
      ]))));
}
