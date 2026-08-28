import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  Color _priorityColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (task.priority) {
      case TaskPriority.high:
        return scheme.error;
      case TaskPriority.medium:
        return scheme.tertiary;
      case TaskPriority.low:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _priorityColor(context), width: 2),
                    color: task.isCompleted ? _priorityColor(context) : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? scheme.onSurfaceVariant : scheme.onSurface,
                      ),
                    ),
                    if (task.dueDate != null)
                      Text(
                        DateFormat('MMM d, h:mm a').format(task.dueDate!),
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (task.repeat != RepeatRule.none)
                Icon(Icons.repeat_rounded, size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
