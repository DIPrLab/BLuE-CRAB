import 'package:bluetooth_detector/map_view/map_functions.dart';
import 'package:bluetooth_detector/styles/styles.dart';
import 'package:bluetooth_detector/settings_view/LatLngTile.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:flutter/material.dart';

part "slider.dart";
part "section_header.dart";

class LocationHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddLocation;

  LocationHeader({required this.onAddLocation});

  @override
  Widget build(BuildContext context) => Center(
      child: Container(
          child: ListTile(
              leading: IconButton(icon: Icon(Icons.add), onPressed: onAddLocation), title: Text("Add New Safe Zone"))));

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class SettingsView extends StatefulWidget {
  SettingsView(Settings this.settings, {super.key});

  final Settings settings;

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  void _addLocation() => getLocation().then((location) => setState(() {
        widget.settings.safeZones.add(location);
        widget.settings.save();
      }));

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithoutBackground),
                header("Discover Services"),
                SwitchListTile(
                    title: Text("AutoConnect ${widget.settings.autoConnect ? "On" : "Off"}"),
                    value: widget.settings.autoConnect,
                    onChanged: (bool value) => setState(() => widget.settings.autoConnect = value),
                    secondary: widget.settings.autoConnect ? Icon(Icons.bluetooth) : Icon(Icons.bluetooth_disabled)),
                header("Location Services"),
                SwitchListTile(
                    title: Text("Location ${widget.settings.locationEnabled ? "En" : "Dis"}abled"),
                    value: widget.settings.locationEnabled,
                    onChanged: (bool value) => setState(() => widget.settings.locationEnabled = value),
                    secondary: widget.settings.locationEnabled
                        ? Icon(Icons.location_searching)
                        : Icon(Icons.location_disabled)),
                header("Windowing"),
                settingsSlider(
                    "Window Duration",
                    "${widget.settings.windowDuration().inMinutes.toInt().toString()} minutes",
                    10.0,
                    100.0,
                    widget.settings.windowDurationValue,
                    ((newValue) => widget.settings.windowDurationValue = newValue)),
                header("Time"),
                settingsSlider(
                    "Scanning Time Threshold",
                    "${widget.settings.timeThreshold().inSeconds.toString()} seconds",
                    1.0,
                    100.0,
                    widget.settings.timeThresholdValue,
                    (newValue) => widget.settings.timeThresholdValue = newValue),
                header("Distance"),
                settingsSlider(
                    "Scanning Distance Threshold",
                    "${widget.settings.distanceThreshold().toInt().toString()} meters",
                    1.0,
                    100.0,
                    widget.settings.distanceThresholdValue,
                    (newValue) => widget.settings.distanceThresholdValue = newValue),
                header("Safe Zones"),
                LocationHeader(onAddLocation: _addLocation),
                ...widget.settings.safeZones.map((location) => LatLngTile(location)),
                header("Developer Mode"),
                SwitchListTile(
                    title: Text("Developer Mode ${widget.settings.devMode ? "On" : "Off"}"),
                    value: widget.settings.devMode,
                    onChanged: ((val) => setState(() => widget.settings.devMode = val)),
                    secondary: widget.settings.devMode ? Icon(Icons.developer_board) : Icon(Icons.developer_board_off)),
              ]))));
}
