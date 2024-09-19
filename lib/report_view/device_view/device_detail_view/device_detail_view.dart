import 'package:bluetooth_detector/report_view/device_view/device_detail_view/property_table_view.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:bluetooth_detector/styles/styles.dart';
import 'package:bluetooth_detector/settings.dart';

class DeviceDetailView extends StatelessWidget {
  final Device device;
  final Settings settings;

  DeviceDetailView(this.device, this.settings);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Column(children: [
                  Stack(children: [
                    Row(children: [
                      BackButton(
                        onPressed: () => Navigator.pop(context),
                        style: AppButtonStyle.buttonWithBackground,
                      ),
                      Spacer(),
                    ]),
                    Row(children: [Spacer(), Text("Device Details", style: TextStyles.title), Spacer()]),
                  ]),
                  PropertyTable(device, settings),
                  TextButton(
                    onPressed: () {},
                    child: Spacer(),
                  ),
                ]))));
  }
}
