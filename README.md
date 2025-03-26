# Blue Crab

Blue Crab is an app that scans for and identifies Bluetooth tracking devices. The goal of this project is to prevent stalking and to provide wider services for more platforms than what is currently offered (i.e. Apple and Google/Android).

Important note before installation:
Blue Crab is not yet functional on Linux, but progress is being made to make it available. Stay tuned!

## Getting Started on Linux
### Prepping your system
- Verify that you have `bash`, `file`, `mkdir`, `rm`, and `which` installed on your device. These binaries (executable programs) should already be pre-installed with the Linux OS.
```
which bash file mkdir rm which
/bin/bash
/usr/bin/file
/bin/mkdir
/bin/rm
which: shell built-in command
```

- Install `curl`, `git`, `unzip`, `xz-utils`, `zip`, and `libglu1-mesa`
```
sudo apt-get update -y && sudo apt-get upgrade -y;
```
```
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
```

- Install `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, and `libstdc++-12-dev`
```
sudo apt-get install \
    clang cmake git \
    ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    libstdc++-12-dev
```

### Downloading and extracting the Flutter SDK
You can download and extract the Flutter SDK using two different methods. The first is using `snap` and is always preferable, but if the first method doesn't work (usually in the rare case where `snap` is not well supported on certain Linux distributions), the second is still very much a viable option.
1. Using `snap`
```
cd
sudo snap install flutter
flutter --version
```
2. To be used only the case where `snap` is not (well) supported
```
cd
mkdir flutter
wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/desktop/flutter_linux_3.22.3-stable.tar.xz
tar xf flutter_linux_3.22.3-stable.tar.xz
```

### Add Flutter to your PATH
Check which shell starts when you open a new console window. This is your default shell.
```
echo $SHELL
```

Based on your default shell, choose one of the commands below.
- `bash`
```
echo 'export PATH="/flutter/bin:$PATH"' >> ~/.bash_profile
```

- `zsh`
```
echo 'export PATH="/flutter/bin:$PATH"' >> ~/.zshenv
```

- `fish`
```
fish_add_path -g -p /flutter/bin
```

- `csh`
```
echo 'setenv PATH "/flutter/bin:$PATH"' >> ~/.cshrc
```

- `tcsh`
```
echo 'setenv PATH "/flutter/bin:$PATH"' >> ~/.tcshrc
```

- `ksh`
```
echo 'export PATH="/flutter/bin:$PATH"' >> ~/.profile
```

- `sh`
```
echo 'export PATH="/flutter/bin:$PATH"' >> ~/.profile
```

To apply this change, restart all open terminal sessions.

### Check your development setup
Open a shell and run the following command:
```
flutter doctor
```

You do not need ALL components. It should resemble something like this:
```
Running flutter doctor...
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.22.1, on Ubuntu 20.04 (LTS), locale en)
[!] Android toolchain - develop for Android devices
[!] Chrome - develop for the web
[!] Android Studio (not installed)
[✓] Linux toolchain - develop for Linux desktop
[✓] VS Code (version 1.89)
[✓] Connected device (1 available)
[✓] Network resources

! Doctor found issues in 3 categories.
```

### Troubleshoot Flutter doctor issues
- Run the following command:
```
flutter doctor -v
```

Note: Installing the Flutter SDK means that all the packages (including the Dart SDK) are already installed, so nothing else has to be installed separately.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Cloning Blue Crab
To clone this repository, run the following:
```
cd /Downloads
git clone git@github.com:DIPrLab/blue_crab.git
```

## Getting packages and setting up your code editor
To get all the Flutter plugins, run the following to get the most updated dependencies available:
```
flutter pub get
flutter pub upgrade
flutter pub upgrade --major-versions
```

Now run this command:
```
flutter pub outdated
```
If there's a package in the generated "table", this is perfectly fine as long as something similar to what is below is generated after this "table".
```
You are already using the newest resolvable versions listed in the 'Resolvable' column.
Newer versions, listed in 'Latest', may not be mutually compatible.
```
If this isn't the case, be sure to run any commands suggested by the program. It may be `flutter pub upgrade --major-versions` a second time, which is fine.

After run all of these commands, you're set to start coding! All files to edit will be in the folder `lib` in files ending in `.dart`.

## Running the app
To run the app, run this command:
```
flutter run
```

When you do so, you should see something similar to what is below. Keep in mind that Blue Crab is not fully functional on Linux, so if operating on Linux, you may see errors.
```
Launching lib/main.dart on Linux in debug mode...
Building Linux application...
✓ Built build/linux/x64/debug/bundle/blue_crab

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

## Learning Dart
Here are a few resources to get started on your Dart learning journey:
- [Dart basics](https://dart.dev/language)
- [Effective Dart](https://dart.dev/effective-dart)
- [Dart libraries](https://dart.dev/libraries)
