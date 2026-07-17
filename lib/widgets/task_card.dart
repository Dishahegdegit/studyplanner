import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/app_colors.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onCompleted;
  // Optional: subject color for the left accent border
  final Color? subjectColor;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleted,
    this.subjectColor,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case "High":
        return AppColors.lobsterPink;
      case "Medium":
        return AppColors.almondSilk;
      case "Low":
        return AppColors.winePlum;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _isOverdue() {
    if (task.completed) return false;
    try {
      final taskDate = DateFormat("dd MMM yyyy").parse(task.date);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);
      return taskDay.isBefore(todayDate);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool overdue = _isOverdue();
    final Color accentColor = subjectColor ?? _priorityColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Subject colour left border ──────────────────────────
              Container(
                width: 5,
                color: accentColor,
              ),
              // ── Main content ────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.completed,
                        onChanged: onCompleted,
                        activeColor: AppColors.lobsterPink,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + overdue badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                if (overdue)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.lobsterPink.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.lobsterPink.withValues(alpha: 0.35)),
                                    ),
                                    child: Text(
                                      '⚠ Overdue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lobsterPink,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              task.subjectName,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: isDark
                                          ? AppColors.linen
                                          : AppColors.midnightViolet,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(task.date,
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isDark
                                          ? AppColors.linen
                                          : AppColors.midnightViolet,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${task.startTime} – ${task.endTime}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _priorityColor().withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  color: _priorityColor(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: Icon(
                              Icons.edit,
                              color:
                                  isDark ? AppColors.linen : AppColors.lobsterPink,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(
                              Icons.delete,
                              color: isDark
                                  ? AppColors.almondSilk
                                  : AppColors.winePlum,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
