import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  late bool autoConnect;
  late bool locationEnabled;
  late double windowDuration;
  late double scanTime;
  late double thresholdTime;
  late double scanDistance;
  late double thresholdDistance;
  late List<LatLng> safeZones;

  loadData() async => SharedPreferences.getInstance().then((prefs) {
        autoConnect = prefs.getBool("autoConnect") ?? false;
        locationEnabled = prefs.getBool("locationEnabled") ?? true;
        windowDuration = prefs.getDouble("windowDuration") ?? 10;
        scanTime = prefs.getDouble("scanTime") ?? 10;
        thresholdTime = prefs.getDouble("thresholdTime") ?? 10;
        scanDistance = prefs.getDouble("scanDistance") ?? 10;
        thresholdDistance = prefs.getDouble("thresholdDistance") ?? 10;
        safeZones = prefs.getStringList("safeZones")?.map((x) {
              List<String> latlng = x.split(',');
              return LatLng.degree(double.tryParse(latlng[0]) ?? 0.0, double.tryParse(latlng[1]) ?? 0.0);
            }).toList() ??
            [];
      });

  void save() => SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("autoConnect", autoConnect);
        prefs.setBool("locationEnabled", locationEnabled);
        prefs.setDouble("scanTime", scanTime);
        prefs.setDouble("thresholdTime", thresholdTime);
        prefs.setDouble("scanDistance", scanTime);
        prefs.setDouble("thresholdDistance", thresholdTime);
        prefs.setStringList("safeZones",
            safeZones.map((z) => "${z.latitude.degrees.toString()},${z.longitude.degrees.toString()}").toList());
      });
}
