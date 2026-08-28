# TaskFlow — QA Report

## Environment constraint (read first)
This build environment has no Flutter/Dart SDK installed and no network
access to `pub.dev` or Flutter's package storage (`storage.googleapis.com`)
— both were tested and confirmed blocked. That means the usual pipeline of
`flutter pub get` → `flutter analyze` → `flutter test` → `flutter run` on an
emulator → `flutter build apk` could not be executed here. Everything below
is **manual static verification**, done file-by-file, in place of a compiler
pass. Treat this as a thorough code review, not a substitute for running
`flutter analyze` and `flutter test` yourself once you unzip the project
(both should be run as your first step — see BUILD_INSTRUCTIONS.md).

## Checks performed and result

| Check | Method | Result |
|---|---|---|
| Balanced braces/parens in every `.dart` file | Scripted count per file | ✅ Pass, all 40+ files |
| Every relative `import '../...'` resolves to a real file | Scripted path resolution | ✅ Pass |
| Every `package:` import has a matching `pubspec.yaml` dependency | Scripted diff | ✅ Pass |
| `copyWith()` call sites vs. model constructor/copyWith signatures | Manual side-by-side read, all 5 mutable models (Task, Reminder, Alarm, Event, Note) | ✅ Pass — parameter names and types match exactly, including `Task.clearDueDate` for nulling out a due date |
| Provider `add*()` method signatures vs. call sites (edit screens + Smart Command bar + habit screen) | Manual side-by-side read, all 6 providers | ✅ Pass |
| `RepeatRule` enum accessibility across files that reference it | Grep + import chain check | ✅ Pass — every file using it imports `data/models/task.dart` directly (Dart imports are not transitive, so this was checked explicitly rather than assumed) |
| `flutter_local_notifications` API usage (`zonedSchedule` positional args, `AndroidNotificationDetails` constructor shape, `fullScreenIntent`, `actions`, `category`) | Cross-referenced against the package's published docs/examples for the pinned version (17.2.2) | ✅ Matches documented usage patterns |
| Database schema vs. model `toMap`/`fromMap` field names | Manual read of `database_helper.dart` against all 6 models | ✅ Pass — column names match map keys exactly |
| Logical correctness of `SmartParser` | Hand-traced 6 representative inputs (see below) + written as executable unit tests in `test/smart_parser_test.dart` | ✅ Traced correctly; **not yet executed** (needs `flutter test`) |

## SmartParser — traced test cases
These are implemented as real tests in `test/smart_parser_test.dart`. Traced
by hand against the parser logic:
- `"Wake me up at 6 AM"` → alarm, 06:00 ✅
- `"Remind me to call the bank at 3 PM"` → reminder, 15:00, title "Call the bank" ✅
- `"Pay electricity bill tomorrow 7 PM"` → task, tomorrow's date, 19:00, title "Pay electricity bill" ✅
- `"Call Rahul Friday 5 PM"` → next Friday, 17:00 ✅
- `"Lunch today 12 PM"` / `"Reset counters 12 AM"` → 12-hour edge cases (noon=12, midnight=0) ✅

## Known limitations / things that need a real device pass
1. **Custom alarm sounds are not bundled.** The alarm sound picker offers
   "gentle", "classic", "chimes" as labels, but the actual `.mp3`/`.ogg`
   files aren't included (binary audio assets can't be authored in this
   text-only environment). Selecting anything other than "Default" will
   fall back silently unless you add real files to
   `android/app/src/main/res/raw/` with matching names before building.
   "Default" uses the system notification sound and works out of the box.
2. **Not run against `flutter analyze`.** Static review catches structural
   issues (imports, signatures, braces) but not every class of type error
   the Dart analyzer would catch. Run `flutter analyze` right after `flutter
   pub get` as your first sanity check.
3. **Not run on an emulator or device.** Navigation flow, dark/light
   rendering across all 3 styles, and responsive layout on different screen
   sizes were designed for (Material 3, `SafeArea`, `Expanded`/`Wrap` used
   throughout instead of fixed sizes) but not visually confirmed on a
   screen. Please do a manual pass through: switching all 3 styles ×
   light/dark, rotating/resizing, and the full add-task-with-due-date →
   receive-notification loop.
4. **OEM battery optimization** (MIUI, ColorOS, One UI aggressive modes) can
   still delay or kill exact alarms at the OS level regardless of app code —
   this is a known Android ecosystem issue, not a bug in this app. The
   Settings screen's "Enable notifications & exact alarms" action requests
   the right permissions, but users on aggressive OEM skins may need to
   manually whitelist the app from battery optimization.
5. **`android/`, `ios/` native folders are not included** — see
   BUILD_INSTRUCTIONS.md for why and the one-command fix (`flutter create
   .`).

## Recommended first commands after unzipping
```bash
flutter create . --project-name taskflow --org com.example
flutter pub get
flutter analyze
flutter test
flutter run
```
If `flutter analyze` surfaces anything, it will almost certainly be minor
(an unused import, a lint suggestion) given the depth of manual
cross-checking already done — but please treat that command, not this
document, as the final authority on compile correctness.
