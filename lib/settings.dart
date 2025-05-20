import 'package:blue_crab/report/classifiers/classifier.dart';
import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  // Factory constructor that returns the shared instance
  factory Settings() => shared;

  // Private constructor
  Settings._internal() {
    loadData();
  }
  // The singleton instance
  static final Settings shared = Settings._internal();

  Classifier classifier = Classifier.classifiers[0];

  late bool demoMode;
  late bool devMode;
  late bool autoConnect;
  late bool locationEnabled;
  late List<LatLng> safeZones;

  // Risk Metrics
  late bool enableDistanceWithUserMetric;
  late bool enableIncidenceMetric;
  late bool enableRSSIMetric;
  late bool enableTimeWithUserMetric;

  // Properties that will be turned into calculated values
  // late int windowDurationValue;
  late double windowDurationValue;
  late double timeThresholdValue;
  late double distanceThresholdValue;

  bool recentlyChanged = false;
  Duration minScanDuration = const Duration(minutes: 10);
  Duration scanInterval = const Duration(minutes: 1);

  // Duration windowDuration() => Duration(hours: windowDurationValue.toInt());
  Duration windowDuration() => Duration(minutes: windowDurationValue.toInt());
  Duration scanTime() => const Duration(seconds: 10);
  Duration timeThreshold() => Duration(seconds: timeThresholdValue.toInt());
  double scanDistance() => 30;
  double distanceThreshold() => distanceThresholdValue;

  void loadData() => SharedPreferences.getInstance().then((prefs) {
        demoMode = prefs.getBool("demoMode") ?? false;
        devMode = prefs.getBool("devMode") ?? false;
        autoConnect = prefs.getBool("autoConnect") ?? false;
        locationEnabled = prefs.getBool("locationEnabled") ?? true;
        safeZones = prefs.getStringList("safeZones")?.map((x) {
              final List<String> latlng = x.split(',');
              return LatLng.degree(double.tryParse(latlng[0]) ?? 0.0, double.tryParse(latlng[1]) ?? 0.0);
            }).toList() ??
            [];

        enableDistanceWithUserMetric = prefs.getBool("enableDistanceWithUserMetric") ?? true;
        enableIncidenceMetric = prefs.getBool("enableIncidenceMetric") ?? true;
        enableRSSIMetric = prefs.getBool("enableRSSIMetric") ?? true;
        enableTimeWithUserMetric = prefs.getBool("enableTimeWithUserMetric") ?? true;

        // windowDurationValue = prefs.getInt("windowDurationValue") ?? 10;
        windowDurationValue = prefs.getDouble("windowDurationValue") ?? 10;
        timeThresholdValue = prefs.getDouble("timeThresholdValue") ?? 10;
        distanceThresholdValue = prefs.getDouble("distanceThresholdValue") ?? 10;
      });

  void save() => SharedPreferences.getInstance().then((prefs) {
        [
          ("demoMode", demoMode),
          ("devMode", devMode),
          ("autoConnect", autoConnect),
          ("locationEnabled", locationEnabled),
          ("enableDistanceWithUserMetric", enableDistanceWithUserMetric),
          ("enableIncidenceMetric", enableIncidenceMetric),
          ("enableRSSIMetric", enableRSSIMetric),
          ("enableTimeWithUserMetric", enableTimeWithUserMetric),
        ].forEach((s) => prefs.setBool(s.$1, s.$2));

        [
          ("windowDurationValue", windowDurationValue),
          ("timeThresholdValue", timeThresholdValue),
          ("distanceThresholdValue", distanceThresholdValue),
        ].forEach((s) => prefs.setDouble(s.$1, s.$2));

        // [
        //   ("windowDurationValue", windowDurationValue),
        // ].forEach((s) => prefs.setInt(s.$1, s.$2.toInt()));

        prefs.setStringList("safeZones", safeZones.map((z) => "${z.latitude.degrees},${z.longitude.degrees}").toList());
      });
}
