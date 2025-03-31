import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/device_view/device_view.dart';
import 'package:blue_crab/report_view/filter_buttons/filter_buttons.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ReportView extends StatefulWidget {
  const ReportView({required this.report, super.key});

  final Report report;

  @override
  ReportViewState createState() => ReportViewState();
}

class ReportViewState extends State<ReportView> {
  late List<Device> devices;
  late int Function(Device, Device) sortMethod;

  @override
  void initState() {
    super.initState();
    sortMethod = byRiskScore;
    sort(sortMethod);
  }

  void sort(int Function(Device a, Device b) sortMethod) => setState(() =>
      devices = widget.report.riskyDevices.map((d) => widget.report.data[d]!).sorted(sortMethod).reversed.toList());

  int byRiskScore(Device a, Device b) => widget.report.riskScore(a).compareTo(widget.report.riskScore(b));

  int byArea(Device a, Device b) => a.areas.length.compareTo(b.areas.length);

  int byTime(Device a, Device b) => a.timeTravelled.compareTo(b.timeTravelled);

  int byIncidence(Device a, Device b) => a.incidence.compareTo(b.incidence);

  int byLocation(Device a, Device b) => a.locations().length.compareTo(b.locations().length);

  Widget sortButton() => PopupMenuButton<dynamic>(
      icon: const Icon(Icons.sort),
      itemBuilder: (context) => [
            ("Risk", byRiskScore),
            ("Incidence", byIncidence),
            ("Location", byLocation),
            ("Time", byTime),
            ("Areas", byArea),
          ]
              .map((e) => PopupMenuItem(
                  child: ListTile(title: Text("Sorte By ${e.$1}")),
                  onTap: () {
                    sortMethod = e.$2;
                    sort(sortMethod);
                  }))
              .toList());

  Widget header(BuildContext context) => Padding(
      padding: const EdgeInsets.all(4),
      child: Stack(children: [
        Row(children: [
          const Spacer(),
          Text("Report", textAlign: TextAlign.center, style: TextStyles.title),
          const Spacer(),
        ]),
        BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithoutBackground),
        Row(children: [const Spacer(), sortButton()])
      ]));

  List<Widget> deviceTileList(BuildContext context) => devices
      .map((device) => DeviceView(device, report: widget.report))
      .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: w))
      .toList();

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SingleChildScrollView(
              child: Column(children: [
        header(context),
        FilterButtonBar(notify: () => setState(() => sort(sortMethod))),
        Column(children: deviceTileList(context)),
      ])));
}
