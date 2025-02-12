import 'dart:isolate';
import 'package:bluetooth_detector/report_view/filter_buttons/filter_buttons.dart';
import 'package:bluetooth_detector/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detector/report_view/device_view/device_view.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/report/device/device.dart';
import 'package:bluetooth_detector/settings.dart';

class ReportView extends StatefulWidget {
  ReportView(Settings this.settings, {super.key, required this.report});

  final Report report;
  final Settings settings;

  @override
  ReportViewState createState() => ReportViewState();
}

class ReportViewState extends State<ReportView> {
  late List<Device?> devices;

  @override
  void initState() {
    super.initState();
    Isolate.run(() => widget.report.refreshCache(widget.settings));
    sort(byRiskScore);
  }

  void sort(int sortMethod(Device a, Device b)) => setState(() => devices = widget.report
      .devices()
      .where((device) => device != null)
      .map((device) => device!)
      .where((device) =>
          widget.report.riskScore(device, widget.settings) > widget.report.riskScoreStats.tukeyExtremeUpperLimit)
      .sorted(sortMethod)
      .reversed
      .toList());

  int byRiskScore(Device a, Device b) =>
      widget.report.riskScore(a, widget.settings).compareTo(widget.report.riskScore(b, widget.settings));

  int byArea(Device a, Device b) => a.areas.length.compareTo(b.areas.length);

  int byTime(Device a, Device b) => a.timeTravelled.compareTo(b.timeTravelled);

  int byIncidence(Device a, Device b) => a.incidence.compareTo(b.incidence);

  int byLocation(Device a, Device b) =>
      a.locations(widget.settings).length.compareTo(b.locations(widget.settings).length);

  Widget sortButton() => PopupMenuButton<dynamic>(
      icon: const Icon(Icons.sort),
      itemBuilder: (BuildContext context) => [
            ("Risk", byRiskScore),
            ("Incidence", byIncidence),
            ("Location", byLocation),
            ("Time", byTime),
            ("Areas", byArea),
          ]
              .map((e) => (ListTile(title: Text("Sort By ${e.$1}")), e.$2))
              .map((e) => PopupMenuItem(child: e.$1, onTap: () => sort(e.$2)))
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
        Row(children: [Spacer(), sortButton()])
      ]));

  List<Widget> deviceTileList(BuildContext context) => devices
      .map((device) => DeviceView(device!, widget.settings, report: widget.report))
      .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), child: w))
      .toList();

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SingleChildScrollView(
              child: Column(children: [
        header(context),
        FilterButtonBar(widget.settings),
        Column(children: deviceTileList(context)),
      ])));
}
