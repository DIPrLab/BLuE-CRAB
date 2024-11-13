import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  late bool devMode;
  late bool autoConnect;
  late bool locationEnabled;
  late double windowDurationValue;
  late double timeThresholdValue;
  late double distanceThresholdValue;
  late List<LatLng> safeZones;

  Duration windowDuration() => Duration(minutes: windowDurationValue.toInt());
  Duration scanTime() => Duration(seconds: 10);
  Duration timeThreshold() => Duration(seconds: timeThresholdValue.toInt());
  double scanDistance() => 30;
  double distanceThreshold() => distanceThresholdValue;

  void loadData() async => SharedPreferences.getInstance().then((prefs) {
        devMode = prefs.getBool("devMode") ?? false;
        autoConnect = prefs.getBool("autoConnect") ?? false;
        locationEnabled = prefs.getBool("locationEnabled") ?? true;
        windowDurationValue = prefs.getDouble("windowDurationValue") ?? 10;
        timeThresholdValue = prefs.getDouble("timeThreshold") ?? 10;
        distanceThresholdValue = prefs.getDouble("distanceThreshold") ?? 10;
        safeZones = prefs.getStringList("safeZones")?.map((x) {
              List<String> latlng = x.split(',');
              return LatLng.degree(double.tryParse(latlng[0]) ?? 0.0, double.tryParse(latlng[1]) ?? 0.0);
            }).toList() ??
            [];
      });

  void save() => SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("devMode", devMode);
        prefs.setBool("autoConnect", autoConnect);
        prefs.setBool("locationEnabled", locationEnabled);
        prefs.setDouble("windowDurationValue", windowDurationValue);
        prefs.setDouble("timeThreshold", timeThresholdValue);
        prefs.setDouble("distanceThreshold", distanceThresholdValue);
        prefs.setStringList("safeZones",
            safeZones.map((z) => "${z.latitude.degrees.toString()},${z.longitude.degrees.toString()}").toList());
      });
}
