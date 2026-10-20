import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../services/dashboard_service.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/dashboard_card.dart';
import 'ai_assistant_screen.dart';
import 'pomodoro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService dashboardService = DashboardService();
  final SubjectService subjectService = SubjectService();
  final TaskService taskService = TaskService();

  int subjects = 0;
  bool loading = true;
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

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

  int _compareTimes(String aStr, String bStr) {
    try {
      final format = DateFormat.jm();
      final aTime = format.parse(aStr);
      final bTime = format.parse(bStr);
      return aTime.compareTo(bTime);
    } catch (_) {
      return 0;
    }
  }


  Future<void> loadDashboard() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    subjects = await dashboardService.getSubjectCount();

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        userName = userDoc.data()!['name'] ?? "";
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Study Planner"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<List<SubjectModel>>(
              stream: subjectService.getSubjects(),
              builder: (context, subjectSnapshot) {
                final subjectColors = <String, Color>{
                  for (final s in subjectSnapshot.data ?? [])
                    s.id: Color(s.color)
                };
                return StreamBuilder<List<TaskModel>>(
                  stream: taskService.getTasks(),
                  builder: (context, snapshot) {
                    final tasksList = snapshot.data ?? [];

                    final int totalTasks = tasksList.length;
                    final int completedTasksCount =
                        tasksList.where((t) => t.completed).length;
                    final int pendingTasksCount =
                        tasksList.where((t) => !t.completed).length;

                    // Calculate completed & pending task hours
                    double completedHours = 0.0;
                    double pendingHours = 0.0;

                    for (final task in tasksList) {
                      final duration = _calculateDurationInHours(
                        task.startTime,
                        task.endTime,
                      );
                      if (task.completed) {
                        completedHours += duration;
                      } else {
                        pendingHours += duration;
                      }
                    }

                    final double totalHoursGoal = completedHours + pendingHours;
                    final double progress = totalHoursGoal > 0
                        ? (completedHours / totalHoursGoal)
                        : 0.0;
                    final percentage = (progress * 100).toStringAsFixed(0);

                    // Filter for Today's tasks
                    final todayStr =
                        DateFormat("dd MMM yyyy").format(DateTime.now());
                    final todaysTasks = tasksList
                        .where((t) => t.date == todayStr)
                        .toList();
                    todaysTasks.sort(
                      (a, b) => _compareTimes(a.startTime, b.startTime),
                    );

                    return RefreshIndicator(
                      onRefresh: loadDashboard,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            userName.isNotEmpty
                                ? "Welcome Back, $userName "
                                : "Welcome Back ",
                            style: AppStyles.heading,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Let's make today productive.",
                            style: AppStyles.subtitle,
                          ),
                          const SizedBox(height: 30),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.3,
                            children: [
                              DashboardCard(
                                icon: Icons.menu_book,
                                title: "Subjects",
                                value: subjects.toString(),
                                color: AppColors.winePlum,
                              ),
                              DashboardCard(
                                icon: Icons.assignment,
                                title: "Tasks",
                                value: totalTasks.toString(),
                                color: AppColors.lobsterPink,
                              ),
                              DashboardCard(
                                icon: Icons.check_circle,
                                title: "Completed",
                                value: completedTasksCount.toString(),
                                color: AppColors.winePlum,
                              ),
                              DashboardCard(
                                icon: Icons.pending_actions,
                                title: "Pending",
                                value: pendingTasksCount.toString(),
                                color: AppColors.almondSilk,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Weekly Goal Progress",
                                    style: AppStyles.title,
                                  ),
                                  const SizedBox(height: 18),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 10,
                                      backgroundColor:
                                          AppColors.cardSecondary.withValues(
                                        alpha: 0.5,
                                      ),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Completed: ${completedHours.toStringAsFixed(1)} / ${totalHoursGoal.toStringAsFixed(1)} hrs",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "$percentage% Completed",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PomodoroScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.lobsterPink,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lobsterPink.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Start Focus Session",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Stay focused and achieve your study goals.",
                                          style: TextStyle(
                                            color: AppColors.linen,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Upcoming Tasks",
                            style: AppStyles.title,
                          ),
                          const SizedBox(height: 12),
                          if (todaysTasks.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "No upcoming tasks.",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: todaysTasks.map((task) {
                                Color priorityColor = AppColors.textMuted;
                                if (task.priority == "High") {
                                  priorityColor = AppColors.lobsterPink;
                                }
                                if (task.priority == "Medium") {
                                  priorityColor = const Color(0xFF8A5A67);
                                }
                                if (task.priority == "Low") {
                                  priorityColor = const Color(0xFF4CAF50);
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      width: 4,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: subjectColors[task.subjectId] ?? priorityColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        decoration: task.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${task.subjectName} · ${task.date} at ${task.startTime}",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (task.completed)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.lobsterPink,
                                            size: 20,
                                          ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: priorityColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            task.priority,
                                            style: TextStyle(
                                              color: priorityColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        floatingActionButton: Builder(
          builder: (context) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            // Light: deep winePlum with linen icon — high contrast on the pink gradient bg
            // Dark:  linen cream with winePlum icon — pops on the dark violet bg
            final Color bg = isDark ? AppColors.linen : AppColors.winePlum;
            final Color iconCol = isDark ? AppColors.winePlum : AppColors.linen;

            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.linen : AppColors.winePlum)
                        .withValues(alpha: isDark ? 0.25 : 0.55),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: bg,
                foregroundColor: iconCol,
                tooltip: 'AI Assist',
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AIAssistantScreen(),
                    ),
                  );
                },
                child: Icon(Icons.auto_awesome, color: iconCol, size: 24),
              ),
            );
          },
        ),
      ),
    );
  }
}
