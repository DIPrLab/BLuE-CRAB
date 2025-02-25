import 'package:blue_crab/map_view/map_functions.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:blue_crab/settings_view/LatLngTile.dart';
import 'package:blue_crab/settings.dart';
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
  SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  void _addLocation() => getLocation().then((location) => setState(() {
        Settings.shared.recentlyChanged = true;
        Settings.shared.safeZones.add(location);
        Settings.shared.save();
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
                    title: Text("AutoConnect ${Settings.shared.autoConnect ? "On" : "Off"}"),
                    value: Settings.shared.autoConnect,
                    onChanged: (bool value) => setState(() => Settings.shared.autoConnect = value),
                    secondary: Settings.shared.autoConnect ? Icon(Icons.bluetooth) : Icon(Icons.bluetooth_disabled)),
                header("Location Services"),
                SwitchListTile(
                    title: Text("Location ${Settings.shared.locationEnabled ? "En" : "Dis"}abled"),
                    value: Settings.shared.locationEnabled,
                    onChanged: (bool value) => setState(() => Settings.shared.locationEnabled = value),
                    secondary: Settings.shared.locationEnabled
                        ? Icon(Icons.location_searching)
                        : Icon(Icons.location_disabled)),
                header("Windowing"),
                settingsSlider(
                    "Window Duration",
                    "${Settings.shared.windowDuration().inMinutes.toInt().toString()} minutes",
                    10.0,
                    100.0,
                    Settings.shared.windowDurationValue, ((newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.windowDurationValue = newValue;
                })),
                header("Time"),
                settingsSlider(
                    "Scanning Time Threshold",
                    "${Settings.shared.timeThreshold().inSeconds.toString()} seconds",
                    1.0,
                    100.0,
                    Settings.shared.timeThresholdValue, (newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.timeThresholdValue = newValue;
                }),
                header("Distance"),
                settingsSlider(
                    "Scanning Distance Threshold",
                    "${Settings.shared.distanceThreshold().toInt().toString()} meters",
                    1.0,
                    100.0,
                    Settings.shared.distanceThresholdValue, (newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.distanceThresholdValue = newValue;
                }),
                header("Safe Zones"),
                LocationHeader(onAddLocation: _addLocation),
                ...Settings.shared.safeZones.map((location) => LatLngTile(location)),
                header("Developer Mode"),
                SwitchListTile(
                    title: Text("Developer Mode ${Settings.shared.devMode ? "On" : "Off"}"),
                    value: Settings.shared.devMode,
                    onChanged: ((val) => setState(() => Settings.shared.devMode = val)),
                    secondary: Settings.shared.devMode ? Icon(Icons.developer_board) : Icon(Icons.developer_board_off)),
              ]))));
}
