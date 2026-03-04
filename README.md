# BL(u)E CRAB

Detecting malicious Bluetooth Low Energy (BLE) trackers remains challenging because existing approaches rely on fixed time and distance thresholds that are brittle across environments. This results in false positives or requires long observation windows. To address these limitations, we present BL(u)E CRAB, a cross-platform (iOS/Android) mobile system that represents nearby devices using three risk factors derived from BLE scan data. Our detection model adapts Clustering-Based Local Outlier Factor (CBLOF) to BLE tracker detection and adds a gap-thresholding mechanism to separate high-scoring outliers from the benign majority. Across micro-benchmarks and end-to-end case studies, CBLOF reduces false positives up to 77%  and false negatives up to 20% compared to the state of the art. In our case studies, suspicious trackers are typically detected within 5 minutes of scanning, improving practical usability for real-world deployment.

## Install Flutter

Install and set up Flutter following the instructions in [the official documentation](https://docs.flutter.dev/install/quick).

To check your development setup, open a terminal and run the following command:

```
flutter doctor
```

You do not need ALL components. It should resemble something like this:

```
Running flutter doctor...
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.35.7, on macOS 26.3 25D125 darwin-arm64, locale en-US)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS (Xcode 26.3)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.2)
[✓] VS Code (version 1.89)
[✓] Connected device (1 available)
[✓] Network resources
```

### Troubleshooting

To troubleshoot Flutter issues, run the following command:

```
flutter doctor -v
```

## Clone BL(u)E CRAB and Get Dependencies

Clone the repository and get the necessary depencies by run the following:

```
git clone git@github.com:DIPrLab/BLuE-CRAB.git

flutter pub get
flutter pub upgrade
flutter pub upgrade --major-versions
```

## Running the app

To start the app, run the command:

```
flutter run
```
