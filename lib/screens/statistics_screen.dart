import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../models/pomodoro_model.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../services/pomodoro_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/progress_pie_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  /// Parses start/end time strings and returns duration in hours (double).
  double _taskHours(TaskModel task) {
    try {
      final start = DateFormat.jm().parse(task.startTime);
      var end = DateFormat.jm().parse(task.endTime);
      if (end.isBefore(start)) end = end.add(const Duration(days: 1));
      return end.difference(start).inMinutes / 60.0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectService = SubjectService();
    final taskService = TaskService();
    final pomodoroService = PomodoroService();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent =
        isDark ? AppColors.linen : AppColors.vividPink;
    final Color warmAccent =
        isDark ? const Color(0xFFFFD7A8) : AppColors.winePlum;

    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Statistics'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: StreamBuilder<List<SubjectModel>>(
        stream: subjectService.getSubjects(),
        builder: (context, subjectSnap) {
          return StreamBuilder<List<TaskModel>>(
            stream: taskService.getTasks(),
            builder: (context, taskSnap) {
              return StreamBuilder<List<PomodoroModel>>(
                stream: pomodoroService.getSessions(),
                builder: (context, pomodoroSnap) {
                  if (subjectSnap.connectionState == ConnectionState.waiting ||
                      taskSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final subjects = subjectSnap.data ?? [];
                  final tasks = taskSnap.data ?? [];
                  final sessions = pomodoroSnap.data ?? [];

                  // ── Core counts ──
                  final int totalTasks = tasks.length;
                  final int completedTasks =
                      tasks.where((t) => t.completed).length;
                  final int pendingTasks = totalTasks - completedTasks;
                  final double overallProgress =
                      totalTasks == 0 ? 0 : completedTasks / totalTasks;

                  // ── Study hours per subject (completed tasks only) ──
                  final Map<String, double> subjectHours = {};
                  for (final task in tasks) {
                    if (task.completed) {
                      subjectHours[task.subjectName] =
                          (subjectHours[task.subjectName] ?? 0) +
                              _taskHours(task);
                    }
                  }

                  // ── Most studied subject ──
                  String mostStudied = '—';
                  if (subjectHours.isNotEmpty) {
                    mostStudied = subjectHours.entries
                        .reduce((a, b) => a.value >= b.value ? a : b)
                        .key;
                  }

                  // ── Average study hours per day ─
                  final Map<String, double> perDay = {};
                  for (final task in tasks) {
                    if (task.completed) {
                      perDay[task.date] =
                          (perDay[task.date] ?? 0) + _taskHours(task);
                    }
                  }
                  final double avgPerDay = perDay.isEmpty
                      ? 0
                      : perDay.values.reduce((a, b) => a + b) / perDay.length;

                  // ── Pomodoro sessions ──
                  final int pomodoroSessions = sessions.length;
                  final int pomodoroMinutes = sessions.fold(
                      0, (sum, s) => sum + s.minutes);

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      //  Header
                      Text('Study Progress', style: AppStyles.heading),
                      const SizedBox(height: 4),
                      Text('Track your learning journey',
                          style: AppStyles.subtitle),
                      const SizedBox(height: 24),

                      // ── Overall progress card
                      _SectionCard(
                        title: 'Overall Progress',
                        icon: Icons.bar_chart_rounded,
                        iconColor: primaryAccent,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: overallProgress,
                              minHeight: 14,
                              borderRadius: BorderRadius.circular(20),
                              backgroundColor:
                                  AppColors.cardSecondary.withValues(alpha: 0.24),
                              color: primaryAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${(overallProgress * 100).toStringAsFixed(0)}% Completed',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Pie chart
                      ProgressPieChart(
                        completed: completedTasks,
                        pending: pendingTasks,
                      ),
                      const SizedBox(height: 20),

                      // ── Quick stats row
                      _QuickStatsRow(
                        items: [
                          _QuickStat(
                            icon: Icons.assignment_turned_in,
                            label: 'Completed',
                            value: '$completedTasks',
                            color: primaryAccent,
                          ),
                          _QuickStat(
                            icon: Icons.pending_actions,
                            label: 'Pending',
                            value: '$pendingTasks',
                            color: warmAccent,
                          ),
                          _QuickStat(
                            icon: Icons.menu_book,
                            label: 'Subjects',
                            value: '${subjects.length}',
                            color: primaryAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Pomodoro stats
                      _SectionCard(
                        title: 'Pomodoro Sessions',
                        icon: Icons.timer,
                        iconColor: primaryAccent,
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.repeat,
                                label: 'Total Sessions',
                                value: '$pomodoroSessions',
                                color: primaryAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.access_time,
                                label: 'Total Minutes',
                                value: '$pomodoroMinutes min',
                                color: warmAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Study averages
                      _SectionCard(
                        title: 'Study Insights',
                        icon: Icons.insights,
                        iconColor: primaryAccent,
                        child: Column(
                          children: [
                            _InsightRow(
                              icon: Icons.today,
                              iconColor: primaryAccent,
                              label: 'Avg Study Time / Day',
                              value:
                                  '${avgPerDay.toStringAsFixed(1)} hrs',
                            ),
                            const Divider(),
                            _InsightRow(
                              icon: Icons.star,
                              iconColor: warmAccent,
                              label: 'Most Studied Subject',
                              value: mostStudied,
                            ),
                            const Divider(),
                            _InsightRow(
                              icon: Icons.check_circle,
                              iconColor: primaryAccent,
                              label: 'Completion Rate',
                              value:
                                  '${(overallProgress * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Subject-wise hours & goal progress ───
                      _SectionCard(
                        title: 'Subject Goal Progress',
                        icon: Icons.school,
                        iconColor: primaryAccent,
                        child: subjects.isEmpty
                            ? const Text('No subjects found.')
                            : Column(
                                children: subjects.map((subject) {
                                  final hours =
                                      subjectHours[subject.name] ?? 0.0;
                                  final goal = subject.weeklyGoal.toDouble();
                                  final progressVal =
                                      goal == 0 ? 0.0 : (hours / goal).clamp(0.0, 1.0);
                                  final pct =
                                      (progressVal * 100).toStringAsFixed(0);
                                  final achieved = progressVal >= 1.0;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                subject.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (achieved)
                                              Text('Goal Achieved!',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryAccent,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            else
                                              Text(
                                                '$pct%',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: progressVal,
                                          minHeight: 10,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          backgroundColor:
                                              AppColors.cardSecondary.withValues(alpha: 0.24),
                                          color: Color(subject.color),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${hours.toStringAsFixed(1)} / ${goal.toStringAsFixed(0)} hrs',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),

                      // ── Weekly Bar Chart ─
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Weekly Study Hours',
                        icon: Icons.bar_chart,
                        iconColor: primaryAccent,
                        child: _WeeklyBarChart(
                          hoursPerDay: perDay,
                          barColor: primaryAccent,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  );
                },
              );
            },
          );
        },
        ),
      ),
    );
  }
}

// ── Helper Widgets ─

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconColor.withValues(alpha: isDark ? 0.28 : 0.16),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final List<_QuickStat> items;
  const _QuickStatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: item.color.withValues(alpha: isDark ? 0.24 : 0.14),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(item.value,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(item.label,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickStat {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _QuickStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.40 : 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: isDark ? 0.24 : 0.14),
            child: Icon(
              icon,
              color: isDark ? AppColors.linen : color,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withValues(alpha: isDark ? 0.24 : 0.14),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Bar Chart ─
class _WeeklyBarChart extends StatelessWidget {
  final Map<String, double> hoursPerDay;
  final Color barColor;

  const _WeeklyBarChart({
    required this.hoursPerDay,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // weekday: 1=Mon … 7=Sun
    final int weekdayIndex = today.weekday; // 1-based
    final DateTime monday =
        today.subtract(Duration(days: weekdayIndex - 1));

    final fmt = DateFormat('dd MMM yyyy');
    final List<double> values = List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final key = fmt.format(day);
      return hoursPerDay[key] ?? 0.0;
    });

    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _BarChartPainter(
          values: values,
          barColor: barColor,
          todayIndex: weekdayIndex - 1, // 0-based
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final int todayIndex;

  static const List<String> _dayLabels = [
    'M', 'T', 'W', 'T', 'F', 'S', 'S'
  ];

  const _BarChartPainter({
    required this.values,
    required this.barColor,
    required this.todayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 36.0;
    const double bottomPad = 36.0;
    const double topPad = 20.0;
    const double barRadius = 6.0;

    final double chartWidth = size.width - leftPad;
    final double chartHeight = size.height - bottomPad - topPad;
    final double maxVal = values.fold(0.0, (m, v) => v > m ? v : m);
    final double effectiveMax = maxVal < 1.0 ? 4.0 : maxVal * 1.15;

    // ── Baseline ─
    final baselinePaint = Paint()
      ..color = AppColors.cardSecondary
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(leftPad, size.height - bottomPad),
      Offset(size.width, size.height - bottomPad),
      baselinePaint,
    );

    // ── Y-axis labels ──
    final labelStyle = TextStyle(
      fontSize: 10,
      color: AppColors.textMuted,
    );
    void drawYLabel(String text, double y) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    drawYLabel('0', size.height - bottomPad);
    drawYLabel(
      effectiveMax.toStringAsFixed(effectiveMax < 2 ? 1 : 0),
      topPad,
    );

    // ── Bars ───
    const int count = 7;
    const double barGapRatio = 0.35;
    final double slotWidth = chartWidth / count;
    final double barWidth = slotWidth * (1 - barGapRatio);

    for (int i = 0; i < count; i++) {
      final double hours = values[i];
      final double barH = hours == 0
          ? 0
          : (hours / effectiveMax * chartHeight).clamp(6.0, chartHeight);

      final double left = leftPad + i * slotWidth + (slotWidth - barWidth) / 2;
      final double top = size.height - bottomPad - barH;
      final double right = left + barWidth;
      final double bottom = size.height - bottomPad;

      final bool isToday = i == todayIndex;
      final Color baseColor = isToday ? barColor : barColor.withAlpha(180);
      final Color topColor = isToday
          ? Color.alphaBlend(Colors.white.withAlpha(60), baseColor)
          : baseColor;

      if (hours > 0) {
        final rect = RRect.fromLTRBR(
          left, top, right, bottom,
          const Radius.circular(barRadius),
        );
        final shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, baseColor],
        ).createShader(Rect.fromLTRB(left, top, right, bottom));

        final barPaint = Paint()..shader = shader;
        canvas.drawRRect(rect, barPaint);

        if (isToday) {
          final borderPaint = Paint()
            ..color = barColor.withAlpha(100)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawRRect(rect, borderPaint);
        }

        // Hours value above bar
        final valStyle = TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isToday ? barColor : AppColors.textMuted,
        );
        final valTp = TextPainter(
          text: TextSpan(
            text: hours < 10
                ? hours.toStringAsFixed(1)
                : hours.toStringAsFixed(0),
            style: valStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(
          canvas,
          Offset(
            left + barWidth / 2 - valTp.width / 2,
            top - valTp.height - 2,
          ),
        );
      }

      // Day label below
      final dayStyle = TextStyle(
        fontSize: 11,
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        color: isToday ? barColor : AppColors.textMuted,
      );
      final dayTp = TextPainter(
        text: TextSpan(text: _dayLabels[i], style: dayStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dayTp.paint(
        canvas,
        Offset(
          left + barWidth / 2 - dayTp.width / 2,
          size.height - bottomPad + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values != values ||
      old.barColor != barColor ||
      old.todayIndex != todayIndex;
}
