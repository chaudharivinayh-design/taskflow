import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/alarm_provider.dart';
import 'providers/note_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/event_provider.dart';
import 'services/notification_service.dart';
import 'widgets/root_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..load()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()..load()),
        ChangeNotifierProvider(create: (_) => NoteProvider()..load()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..load()),
        ChangeNotifierProvider(create: (_) => EventProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.build(settings.style, Brightness.light),
            darkTheme: AppTheme.build(settings.style, Brightness.dark),
            home: settings.loaded
                ? const RootScaffold()
                : const _SplashScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 56),
            SizedBox(height: 12),
            Text('TaskFlow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Tasks. Reminders. Alarms. Simplified.'),
          ],
        ),
      ),
    );
  }
}
