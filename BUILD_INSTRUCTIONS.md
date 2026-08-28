# Building TaskFlow into a real APK

This ZIP contains the **complete, hand-written Dart/Flutter source** for
TaskFlow: models, database layer, repositories, providers, notification/alarm
service, the smart-command parser, and every screen. It does **not** include
the auto-generated `android/`, `ios/`, `.dart_tool/`, or `pubspec.lock`
folders, because those are large, machine-generated scaffolding that the
Flutter SDK produces from a template — they aren't meant to be hand-written,
and the sandbox this project was built in has no network access to
`pub.dev` or the Flutter SDK, so it could not run `flutter create`,
`flutter pub get`, or `flutter build apk` itself to verify a byte-for-byte
compiled output. Follow the steps below on your own machine (5–10 minutes)
to get a running app and a release APK. This is the standard workflow for
turning any Flutter source drop into a build.

## 1. Install prerequisites (one-time)
- Flutter SDK 3.22+ (`flutter --version` to confirm) — https://docs.flutter.dev/get-started/install
- Android Studio or just the Android SDK command-line tools + a device/emulator
- Run `flutter doctor` and resolve any red ✗ items

## 2. Unzip and scaffold the native shell
```bash
unzip taskflow_source.zip -d taskflow
cd taskflow
flutter create . --project-name taskflow --org com.example
```
`flutter create .` generates `android/`, `ios/`, `web/`, etc. in place
**without touching your existing `lib/` folder or `pubspec.yaml`** since a
`lib/` directory already exists — Flutter only fills in the missing native
scaffolding.

## 3. Apply the Android manifest additions
Open `android/app/src/main/AndroidManifest.xml` and copy in the permissions
and receivers from `android_manifest_snippet/AndroidManifest_additions.xml`
in this ZIP (exact instructions are in that file's comments). This step is
required for alarms/reminders to fire when the app is closed.

Also confirm in `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21     // flutter_local_notifications requires 21+
    targetSdkVersion 34
}
```

## 4. Fetch packages
```bash
flutter pub get
```

## 5. Run it
```bash
flutter devices          # confirm an emulator or USB device is attached
flutter run
```

## 6. Build a release APK
```bash
flutter build apk --release
```
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```
Install it on a device with:
```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 7. First-run checklist on a real device
- Grant the notification permission when prompted (Android 13+).
- Go to **Settings → Notifications** inside the app and tap
  "Enable notifications & exact alarms" to request the exact-alarm
  permission (Android 12+ shows a system settings page for this).
- Some OEM Android skins (Xiaomi/MIUI, Oppo, Huawei, Samsung's aggressive
  battery saver) kill background alarms unless the app is whitelisted from
  battery optimization — if alarms feel late, disable battery optimization
  for TaskFlow in system settings.

## What's already been verified by hand
Every `.dart` file was written and manually re-read end-to-end for: matching
braces/imports, correct provider wiring, consistent model field names across
`toMap`/`fromMap`, and consistent method signatures between providers, repos,
and UI call sites. See `QA_REPORT.md` for the full pass/fail checklist and
known limitations.
