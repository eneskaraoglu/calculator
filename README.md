# calculator

A simple Flutter mobile calculator app with:

- A clean dark calculator layout
- Live result preview while typing
- Basic operations: `+`, `-`, `*`, `/`
- `C`, `DEL`, sign toggle, and percent buttons

## What is already in this repo

The Flutter app code is already added:

- `lib/main.dart`
- `pubspec.yaml`
- `analysis_options.yaml`
- `test/widget_test.dart`

This machine does not currently have Flutter on `PATH`, so the native platform
folders have not been generated yet.

## 1. Install Flutter on Windows

Recommended location:

```powershell
%USERPROFILE%\develop\flutter
```

Add this to your user `Path` after extracting the SDK:

```powershell
%USERPROFILE%\develop\flutter\bin
```

Then reopen PowerShell and verify:

```powershell
flutter --version
dart --version
```

## 2. Install Android tools

Install Android Studio, then use `SDK Manager` to install:

- Android SDK Platform API 36
- Android SDK Command-line Tools
- Android SDK Build-Tools
- Android Emulator

After that:

```powershell
flutter doctor --android-licenses
flutter doctor -v
```

## 3. Generate the missing Flutter platform folders

From the repository root:

```powershell
flutter create .
flutter pub get
```

This keeps the calculator app code and adds the missing Android, iOS, web, and
desktop project files.

## 4. Run the calculator app

For Android:

```powershell
flutter run -d android
```

For Chrome:

```powershell
flutter run -d chrome
```

## 5. Validate the project

```powershell
flutter analyze
flutter test
```

## Notes

- `git` is already installed in this environment.
- `JAVA_HOME` is already set in this environment.
- No Android SDK was detected yet.
- No Flutter SDK installation was detected yet.
