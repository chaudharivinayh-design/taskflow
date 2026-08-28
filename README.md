# TaskFlow

**Tasks. Reminders. Alarms. Simplified.**

TaskFlow is a single, calm home for everything you need to get through a day:
to-do tasks, reminders, alarms, a calendar, quick notes, and habits — built
with Flutter, stored fully offline in SQLite, and themeable across three
distinct visual styles.

## Feature summary

| Area | What it does |
|---|---|
| **Home** | Greeting, today's progress ring, today's focus list, due habits, next reminder/next alarm pills, upcoming tasks, and the Smart Command bar. Empty sections hide themselves automatically. |
| **Tasks** | Create/edit/delete, due date + time, priority (low/med/high), repeat (none/daily/weekly/monthly/weekdays), complete/uncomplete. Notifies you at the due time. |
| **Reminders** | One-off or repeating local notifications with a configurable snooze duration and Snooze/Dismiss notification actions. |
| **Alarms** | Real Android alarm-clock behaviour: exact-alarm scheduling, per-weekday repeat, vibration toggle, sound choice, snooze, and full-screen/high-priority delivery so it still fires when the app is closed. |
| **Calendar** | Month view (via `table_calendar`) with a day agenda merging tasks, reminders, and events for the selected day. |
| **Notes** | Quick colour-tagged notes in a 2-column grid, pin support. |
| **Habits** | Daily/weekday-targeted habits with one-tap completion and a running streak counter. |
| **Smart Command bar** | Fully offline natural-language parsing — type "Pay electricity bill tomorrow 7 PM" or "Wake me up at 6 AM" and confirm the detected type + date/time before it's created. |
| **Styles** | Zen (calm neutrals), Pulse (vivid gradients), Fusion (balanced, default) — each with Light/Dark/System variants, persisted across launches. |

## Architecture

```
lib/
  core/
    theme/          # style palettes + ThemeData builder
    utils/           # SmartParser (offline NLP-lite command parsing)
  data/
    models/          # Task, Reminder, Alarm, Note, Habit, Event
    db/              # DatabaseHelper (sqflite schema)
    repositories/     # CRUD per entity
  services/
    notification_service.dart   # scheduling, permissions, alarm logic
  providers/          # ChangeNotifier per entity + settings
  features/
    home/, tasks/, calendar/, alarms/, settings/, add/, smart_command/
  widgets/            # shared UI: root scaffold, empty state, progress ring
test/
  smart_parser_test.dart
```

`main.dart` only wires providers, the theme, and the notification service —
no business logic lives there.

## Getting a running app / APK

See **BUILD_INSTRUCTIONS.md**. In short: `flutter create .`, copy in the
Android manifest additions from `android_manifest_snippet/`, `flutter pub
get`, `flutter run` or `flutter build apk --release`.

## Honesty note on how this was built

This project was produced in a sandboxed environment with **no access to
the Flutter SDK or pub.dev** (both are outside the sandbox's network
allowlist), so it was not possible to run `flutter pub get`, `flutter
analyze`, an emulator, or `flutter build apk` to produce a byte-verified
binary. What you're getting is complete, hand-written, carefully
cross-checked source code — not a stack-traced, running build. Every file
was checked for balanced syntax, resolvable imports, and consistent method
signatures between models/providers/UI (see `QA_REPORT.md` for the full
list of checks performed and what still needs a real device/emulator pass).
This matches the fallback path the brief asked for when a full on-device
build isn't possible in the environment.
