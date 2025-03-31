import 'package:blue_crab/map_view/map_functions.dart';
import 'package:blue_crab/report/classifiers/classifier.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/settings_view/lat_lng_tile.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:flutter/material.dart';

part "dropdown.dart";
part "section_header.dart";
part "slider.dart";

class LocationHeader extends StatelessWidget implements PreferredSizeWidget {
  const LocationHeader({required this.onAddLocation, super.key});
  final VoidCallback onAddLocation;

  @override
  Widget build(BuildContext context) => Center(
      child: ListTile(
          leading: IconButton(icon: const Icon(Icons.add), onPressed: onAddLocation),
          title: const Text("Add New Safe Zone")));

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.notify});

  final VoidCallback? notify;

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  void _addLocation() => getLocation().then((location) => setState(() {
        Settings.shared.recentlyChanged = true;
        Settings.shared.safeZones.add(location);
        Settings.shared.save();
      }));

  void changeClassifier(Classifier? c) => Settings.shared.classifier = c ?? Settings.shared.classifier;

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                BackButton(
                    onPressed: () {
                      Settings.shared.save();
                      Navigator.pop(context);
                    },
                    style: AppButtonStyle.buttonWithoutBackground),
                header("Discover Services"),
                SwitchListTile(
                    title: Text("AutoConnect ${Settings.shared.autoConnect ? "On" : "Off"}"),
                    value: Settings.shared.autoConnect,
                    onChanged: (value) {
                      setState(() => Settings.shared.autoConnect = value);
                      Settings.shared.save();
                    },
                    secondary: Settings.shared.autoConnect
                        ? const Icon(Icons.bluetooth)
                        : const Icon(Icons.bluetooth_disabled)),
                header("Location Services"),
                SwitchListTile(
                    title: Text("Location ${Settings.shared.locationEnabled ? "En" : "Dis"}abled"),
                    value: Settings.shared.locationEnabled,
                    onChanged: (value) {
                      setState(() => Settings.shared.locationEnabled = value);
                      Settings.shared.save();
                    },
                    secondary: Settings.shared.locationEnabled
                        ? const Icon(Icons.location_searching)
                        : const Icon(Icons.location_disabled)),
                header("Windowing"),
                settingsSlider("Window Duration", "${Settings.shared.windowDuration().inMinutes} minutes", 10, 100,
                    Settings.shared.windowDurationValue, (newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.windowDurationValue = newValue;
                }),
                header("Classifier"),
                DropdownButton<Classifier>(
                    value: Settings.shared.classifier,
                    items: Settings.classifiers
                        .map((e) => DropdownMenuItem<Classifier>(value: e, child: Text(e.name)))
                        .toList(),
                    onChanged: (newValue) => setState(() => Settings.shared.classifier = newValue!)),
                header("Time"),
                settingsSlider("Scanning Time Threshold", "${Settings.shared.timeThreshold().inSeconds} seconds", 1,
                    100, Settings.shared.timeThresholdValue, (newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.timeThresholdValue = newValue;
                }),
                header("Distance"),
                settingsSlider("Scanning Distance Threshold", "${Settings.shared.distanceThreshold().toInt()} meters",
                    1, 100, Settings.shared.distanceThresholdValue, (newValue) {
                  Settings.shared.recentlyChanged = true;
                  Settings.shared.distanceThresholdValue = newValue;
                }),
                header("Safe Zones"),
                LocationHeader(onAddLocation: _addLocation),
                ...Settings.shared.safeZones.map(LatLngTile.new),
                header("Mode"),
                SwitchListTile(
                    title: Text("Developer Mode ${Settings.shared.devMode ? "On" : "Off"}"),
                    value: Settings.shared.devMode,
                    onChanged: (val) {
                      setState(() {
                        Settings.shared.devMode = val;
                        Settings.shared.demoMode = !Settings.shared.devMode && Settings.shared.demoMode;
                      });
                      widget.notify?.call();
                      Settings.shared.save();
                    },
                    secondary: Icon(Icons.circle, color: Settings.shared.devMode ? Colors.green : Colors.red)),
                SwitchListTile(
                    title: Text("Demo Mode ${Settings.shared.demoMode ? "On" : "Off"}"),
                    value: Settings.shared.demoMode,
                    onChanged: (val) {
                      setState(() {
                        Settings.shared.demoMode = val;
                        Settings.shared.devMode = !Settings.shared.demoMode && Settings.shared.devMode;
                      });
                      widget.notify?.call();
                      Settings.shared.save();
                    },
                    secondary: Icon(Icons.circle, color: Settings.shared.demoMode ? Colors.green : Colors.red)),
              ]))));
}
