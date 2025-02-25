import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  // The singleton instance
  static final Settings shared = Settings._internal();

  // Private constructor
  Settings._internal() {
    loadData();
  }

  // Factory constructor that returns the shared instance
  factory Settings() => shared;

  late bool devMode;
  late bool autoConnect;
  late bool locationEnabled;
  late List<LatLng> safeZones;

  // Risk Metrics
  late bool enableAreasMetric;
  late bool enableDistanceWithUserMetric;
  late bool enableIncidenceMetric;
  late bool enableRSSIMetric;
  late bool enableTimeWithUserMetric;

  // Properties that will be turned into calculated values
  late double windowDurationValue;
  late double timeThresholdValue;
  late double distanceThresholdValue;

  bool recentlyChanged = false;
  Duration minScanDuration = Duration(minutes: 10);
  Duration scanInterval = Duration(minutes: 10);

  Duration windowDuration() => Duration(minutes: windowDurationValue.toInt());
  Duration scanTime() => Duration(seconds: 10);
  Duration timeThreshold() => Duration(seconds: timeThresholdValue.toInt());
  double scanDistance() => 30;
  double distanceThreshold() => distanceThresholdValue;

  void loadData() => SharedPreferences.getInstance().then((prefs) {
        devMode = prefs.getBool("devMode") ?? false;
        autoConnect = prefs.getBool("autoConnect") ?? false;
        locationEnabled = prefs.getBool("locationEnabled") ?? true;
        safeZones = prefs.getStringList("safeZones")?.map((x) {
              List<String> latlng = x.split(',');
              return LatLng.degree(double.tryParse(latlng[0]) ?? 0.0, double.tryParse(latlng[1]) ?? 0.0);
            }).toList() ??
            [];

        enableAreasMetric = prefs.getBool("enableAreasMetric") ?? true;
        enableDistanceWithUserMetric = prefs.getBool("enableDistanceWithUserMetric") ?? true;
        enableIncidenceMetric = prefs.getBool("enableIncidenceMetric") ?? true;
        enableRSSIMetric = prefs.getBool("enableRSSIMetric") ?? true;
        enableTimeWithUserMetric = prefs.getBool("enableTimeWithUserMetric") ?? true;

        windowDurationValue = prefs.getDouble("windowDurationValue") ?? 10;
        timeThresholdValue = prefs.getDouble("timeThresholdValue") ?? 10;
        distanceThresholdValue = prefs.getDouble("distanceThresholdValue") ?? 10;
      });

  void save() => SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("devMode", devMode);
        prefs.setBool("autoConnect", autoConnect);
        prefs.setBool("locationEnabled", locationEnabled);
        prefs.setStringList("safeZones",
            safeZones.map((z) => "${z.latitude.degrees.toString()},${z.longitude.degrees.toString()}").toList());

        prefs.setBool("enableAreasMetric", enableAreasMetric);
        prefs.setBool("enableDistanceWithUserMetric", enableDistanceWithUserMetric);
        prefs.setBool("enableIncidenceMetric", enableIncidenceMetric);
        prefs.setBool("enableRSSIMetric", enableRSSIMetric);
        prefs.setBool("enableTimeWithUserMetric", enableTimeWithUserMetric);

        prefs.setDouble("windowDurationValue", windowDurationValue);
        prefs.setDouble("timeThresholdValue", timeThresholdValue);
        prefs.setDouble("distanceThresholdValue", distanceThresholdValue);
      });
}
