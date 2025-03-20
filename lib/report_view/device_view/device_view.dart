import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/device_view/device_detail_view/device_detail_view.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:flutter/material.dart';

class DeviceView extends StatelessWidget {
  final Device device;
  final Report report;

  DeviceView(Device this.device, {super.key, required this.report});

  Widget Tile(BuildContext context) => ListTile(
      leading: (report.riskScore(device) > report.riskScoreStats.tukeyExtremeUpperLimit)
          ? CircleAvatar(backgroundColor: colors.warnText, foregroundColor: colors.warnText)
          : (report.riskScore(device) > report.riskScoreStats.tukeyMildUpperLimit)
              ? CircleAvatar(backgroundColor: colors.altText, foregroundColor: colors.altText)
              : CircleAvatar(backgroundColor: Colors.green, foregroundColor: Colors.green),
      title: Text(device.deviceLabel() == device.id ? "" : device.deviceLabel(), style: TextStyles.title2),
      subtitle: Text(device.id, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SafeArea(child: DeviceDetailView(device, report)))));

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: colors.foreground),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Tile(context));
}
