import 'package:bluetooth_detector/report_view/device_view/device_detail_view/device_detail_view.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:bluetooth_detector/styles/themes.dart';

class DeviceView extends StatelessWidget {
  final Settings settings;
  final Device device;
  final Report report;

  DeviceView(Device this.device, Settings this.settings, {super.key, required this.report});

  Widget DataRow(String label, String value) {
    if (value.isEmpty) {
      return SizedBox.shrink();
    }
    String text = label;
    if (label.isNotEmpty) {
      text += ": ";
    }
    text += value;

    return Text(text, textAlign: TextAlign.left);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: colors.foreground),
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: ListTile(
                leading: CircleAvatar(backgroundColor: colors.altText, foregroundColor: colors.altText),
                title: Expanded(
                    child: Text(device.deviceLabel() == device.id ? "" : device.deviceLabel(),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                subtitle: Expanded(child: Text(device.id, maxLines: 2, overflow: TextOverflow.ellipsis)),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SafeArea(child: DeviceDetailView(device, report, settings)))))));
  }
}
