import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/note.dart';
import '../../widgets/empty_state.dart';
import '../home/widgets/task_tile.dart';
import 'task_edit_screen.dart';
import 'note_edit_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Notes'),
            Tab(text: 'Habits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TasksTab(),
          _NotesTab(),
          _HabitsTab(),
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final pending = provider.pending;
    final completed = provider.completed;

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pending.isEmpty && completed.isEmpty) {
      return const Center(
        child: EmptyState(
          emoji: '✅',
          title: 'No tasks yet',
          subtitle: 'Tap + to add your first task.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        ...pending.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskTile(
                task: t,
                onToggle: () => provider.toggleComplete(t),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TaskEditScreen(existing: t))),
              ),
            )),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Completed (${completed.length})',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...completed.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskTile(
                  task: t,
                  onToggle: () => provider.toggleComplete(t),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TaskEditScreen(existing: t))),
                ),
              )),
        ],
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  static const _colors = [
    Color(0xFFFFF3C4),
    Color(0xFFD7F5DC),
    Color(0xFFD7E8FF),
    Color(0xFFFFE0EC),
    Color(0xFFE7DBFF),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    if (provider.loading) return const Center(child: CircularProgressIndicator());
    if (provider.notes.isEmpty) {
      return const Center(
        child: EmptyState(
          emoji: '📝',
          title: 'No notes yet',
          subtitle: 'Quick thoughts, one tap away.',
        ),
      );
    }
    return MasonryLikeGrid(
      notes: provider.notes,
      colors: _colors,
    );
  }
}

/// Simple staggered-feel grid using a plain GridView (2 columns) — avoids
/// pulling in an extra masonry package while still looking lively.
class MasonryLikeGrid extends StatelessWidget {
  final List<Note> notes;
  final List<Color> colors;
  const MasonryLikeGrid({super.key, required this.notes, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final note = notes[i];
        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => NoteEditScreen(existing: note))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors[note.colorIndex % colors.length],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.isPinned)
                  const Icon(Icons.push_pin_rounded, size: 16, color: Colors.black45),
                Expanded(
                  child: Text(
                    note.content,
                    maxLines: 8,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HabitsTab extends StatelessWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    if (provider.loading) return const Center(child: CircularProgressIndicator());
    if (provider.habits.isEmpty) {
      return const Center(
        child: EmptyState(
          emoji: '🔥',
          title: 'No habits yet',
          subtitle: 'Build a streak — tap + to add one.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: provider.habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final h = provider.habits[i];
        final doneToday = h.isCompletedOn(DateTime.now());
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            leading: Text(h.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${h.currentStreak} day streak'),
            trailing: IconButton(
              icon: Icon(
                doneToday ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                color: doneToday ? Theme.of(context).colorScheme.primary : null,
                size: 28,
              ),
              onPressed: () => provider.toggleToday(h),
            ),
            onLongPress: () => provider.deleteHabit(h.id),
          ),
        );
      },
    );
  }
}
