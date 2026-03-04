# BL(u)E CRAB

Detecting unwanted or suspicious Bluetooth Low Energy (BLE)-based trackers is challenging, due in part to cross-platform compatibility issues, and inconsistent detection methods. BL(u)E CRAB identifies suspicious BLE trackers based on various risk factors including the number of encounters, time with the user, distance traveled with the user, number of areas each device appeared in and device proximity to user. BL(u)E CRAB presents this information in an intuitive way to help users determine which devices pose the biggest threat to them based on their context.

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
