import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  final VoidCallback onNotes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onNotes,
    required this.onEdit,
    required this.onDelete,
  });

  double _calculateDurationInHours(String startStr, String endStr) {
    try {
      final format = DateFormat.jm();
      final start = format.parse(startStr);
      var end = format.parse(endStr);

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      final diff = end.difference(start);
      return diff.inMinutes / 60.0;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final taskService = TaskService();

    return StreamBuilder<List<TaskModel>>(
      stream: taskService.getTasks(),
      builder: (context, snapshot) {
        double completedHours = 0.0;

        if (snapshot.hasData) {
          final tasks = snapshot.data!;
          final subjectTasks = tasks.where(
            (t) => t.subjectId == subject.id && t.completed,
          );
          for (final task in subjectTasks) {
            completedHours += _calculateDurationInHours(
              task.startTime,
              task.endTime,
            );
          }
        }

        double progress = subject.weeklyGoal > 0
            ? (completedHours / subject.weeklyGoal)
            : 0.0;
        final bool isGoalAchieved = progress >= 1.0 && subject.weeklyGoal > 0;

        // Cap progress indicator value at 1.0 (100%)
        if (progress > 1.0) {
          progress = 1.0;
        }

        final percentage = (progress * 100).toStringAsFixed(0);

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(subject.color),
                      child: Icon(
                        Icons.menu_book,
                        color: isDark
                            ? AppColors.linen
                            : AppColors.midnightViolet,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Weekly Goal: ${subject.weeklyGoal} hrs",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Completed: ${completedHours.toStringAsFixed(1)} / ${subject.weeklyGoal} hrs",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isGoalAchieved)
                      const Text(
                        "Goal Achieved",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lobsterPink,
                        ),
                      )
                    else
                      Text(
                        "$percentage%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.cardSecondary.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGoalAchieved
                          ? AppColors.lobsterPink
                          : Color(subject.color),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onNotes,
                      icon: Icon(
                        Icons.note_alt,
                        color: isDark
                            ? AppColors.linen
                            : AppColors.midnightViolet,
                      ),
                      label: const Text("Notes"),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit,
                        color: isDark
                            ? AppColors.linen
                            : AppColors.lobsterPink,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        color: isDark
                            ? AppColors.almondSilk
                            : AppColors.winePlum,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
