import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/alarms/alarms_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/add/add_bottom_sheet.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    TasksScreen(),
    CalendarScreen(),
    AlarmsScreen(),
    SettingsScreen(),
  ];

  final _labels = const ['Home', 'Tasks', 'Calendar', 'Alarms', 'Settings'];
  final _icons = const [
    Icons.home_rounded,
    Icons.check_circle_outline_rounded,
    Icons.calendar_month_rounded,
    Icons.alarm_rounded,
    Icons.settings_rounded,
  ];
  final _iconsSelected = const [
    Icons.home_rounded,
    Icons.check_circle_rounded,
    Icons.calendar_month_rounded,
    Icons.alarm_rounded,
    Icons.settings_rounded,
  ];

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_screens.length, (i) {
              // Leave a gap for the notch in the middle.
              if (i == 2) {
                return Row(children: [
                  _navItem(i),
                  const SizedBox(width: 48),
                ]);
              }
              return _navItem(i);
            }),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i) {
    final selected = _index == i;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? _iconsSelected[i] : _icons[i],
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              _labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
