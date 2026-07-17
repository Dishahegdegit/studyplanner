import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_card.dart';
import '../utils/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final TaskService taskService = TaskService();
  final SubjectService subjectService = SubjectService();

  String searchQuery = "";
  String selectedFilter = "All";
  late final TabController _tabController;
  final TextEditingController searchController = TextEditingController();

  /// Default to today, non-nullable since calendar is always on a specific day in Active tab.
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuilds to show/hide the calendar strip
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formats a DateTime to the same format used in TaskModel.date: "dd MMM yyyy".
  String _dateStr(DateTime d) => DateFormat("dd MMM yyyy").format(d);

  DateTime? _getTaskDateTime(TaskModel task) {
    try {
      final datePart = DateFormat("dd MMM yyyy").parse(task.date);
      final timePart = DateFormat.jm().parse(task.startTime);
      return DateTime(
          datePart.year, datePart.month, datePart.day,
          timePart.hour, timePart.minute);
    } catch (_) {
      return null;
    }
  }

  bool _isTaskOverdue(TaskModel task) {
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

  List<TaskModel> _applyFilterAndSort(
    List<TaskModel> tasks, {
    String? selectedDateStr,
  }) {
    final query = searchQuery.toLowerCase();
    var result = tasks.where((task) {
      // Date filter (from weekly strip selection)
      if (selectedDateStr != null && task.date != selectedDateStr) {
        return false;
      }
      final matchesQuery = task.title.toLowerCase().contains(query) ||
          task.subjectName.toLowerCase().contains(query);
      bool matchesFilter;
      switch (selectedFilter) {
        case "High":
          matchesFilter = task.priority.toLowerCase() == "high";
          break;
        case "Medium":
          matchesFilter = task.priority.toLowerCase() == "medium";
          break;
        case "Low":
          matchesFilter = task.priority.toLowerCase() == "low";
          break;
        default:
          matchesFilter = true; // "All" or empty
      }
      return matchesQuery && matchesFilter;
    }).toList();

    // Default Sort: Date/Time chronological
    result.sort((a, b) {
      final at = _getTaskDateTime(a);
      final bt = _getTaskDateTime(b);
      if (at == null || bt == null) return 0;
      return at.compareTo(bt);
    });

    return result;
  }

  // ---------------------------------------------------------------------------
  // Task CRUD
  // ---------------------------------------------------------------------------

  Future<void> _addTask(BuildContext context) async {
    final Map<String, dynamic>? result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddTaskDialog(),
    );
    if (result == null) return;
    await taskService.addTask(TaskModel(
      id: '',
      title: result['title'],
      subjectId: result['subjectId'],
      subjectName: result['subjectName'],
      date: result['date'],
      startTime: result['startTime'],
      endTime: result['endTime'],
      priority: result['priority'],
      completed: false,
    ));
  }

  Future<void> _editTask(BuildContext context, TaskModel task) async {
    final Map<String, dynamic>? result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddTaskDialog(task: task),
    );
    if (result == null) return;
    await taskService.updateTask(TaskModel(
      id: task.id,
      title: result['title'],
      subjectId: task.subjectId,
      subjectName: result['subjectName'],
      date: result['date'],
      startTime: result['startTime'],
      endTime: result['endTime'],
      priority: result['priority'],
      completed: task.completed,
    ));
  }

  Future<void> _deleteTask(BuildContext context, TaskModel task) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text("Are you sure you want to delete '${task.title}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.winePlum, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true) await taskService.deleteTask(task.id);
  }

  Future<void> _toggleTask(TaskModel task) async {
    await taskService.toggleTaskCompletion(task.id, !task.completed);
  }

  // ---------------------------------------------------------------------------
  // Dialogs / Sheets
  // ---------------------------------------------------------------------------

  void _showNotificationsDialog(BuildContext context, List<TaskModel> tasks) {
    final now = DateTime.now();
    final List<MapEntry<TaskModel, DateTime>> received = [];
    for (final task in tasks) {
      final taskTime = _getTaskDateTime(task);
      if (taskTime != null) {
        final reminderTime = taskTime.subtract(const Duration(minutes: 15));
        if (reminderTime.isBefore(now)) {
          received.add(MapEntry(task, reminderTime));
        }
      }
    }
    received.sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.notifications_active, color: AppColors.lobsterPink),
          SizedBox(width: 10),
          Text("Notifications Received"),
        ]),
        content: received.isEmpty
            ? const Text("No notifications received yet.")
            : SizedBox(
                width: 300,
                height: 300,
                child: ListView.builder(
                  itemCount: received.length,
                  itemBuilder: (context, index) {
                    final item = received[index];
                    final task = item.key;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications,
                          color: AppColors.lobsterPink),
                      title: Text(
                        "⏰ ${task.title} (${task.subjectName})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        DateFormat("dd MMM, hh:mm a").format(item.value),
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Weekly Calendar Strip
  // ---------------------------------------------------------------------------

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildWeeklyStrip(List<TaskModel> tasks) {
    final today = DateTime.now();
    // Build 7 days centred on today: today-3 … today+3
    final days = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day)
          .add(Duration(days: i - 3)),
    );

    // Pre-compute which date strings have tasks
    final Set<String> datesWithTasks = {for (final t in tasks) t.date};

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isToday = _isSameDay(day, today);
            final isSelected = _isSameDay(day, selectedDay);
            final dateStr = _dateStr(day);
            final hasTasks = datesWithTasks.contains(dateStr);

            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 64,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Abbreviated day name (Mon, Tue …)
                    Text(
                      DateFormat('E').format(day),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date number with selection circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected && !isToday
                            ? AppColors.primary.withAlpha(30)
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(
                                color: isToday
                                    ? Colors.white
                                    : AppColors.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Task indicator dot
                    AnimatedOpacity(
                      opacity: hasTasks ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Task list builder
  // ---------------------------------------------------------------------------

  Widget _taskList(
    BuildContext context,
    List<TaskModel> allTasks,
    Map<String, Color> subjectColors,
    String tabType,
    AsyncSnapshot snapshot, {
    String? selectedDateStr,
  }) {
    // Active filters by date, Done and Overdue do not filter by selected date
    final filtered = _applyFilterAndSort(
      allTasks,
      selectedDateStr: tabType == "Active" ? selectedDateStr : null,
    ).where((t) {
      if (tabType == "Done") {
        return t.completed;
      } else if (tabType == "Overdue") {
        return !t.completed && _isTaskOverdue(t);
      } else {
        // "Active"
        return !t.completed;
      }
    }).toList();

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text(snapshot.error.toString()));
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tabType == "Done" ? Icons.task_alt : Icons.search_off,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              tabType == "Done"
                  ? "No completed tasks"
                  : tabType == "Overdue"
                      ? "No overdue tasks"
                      : "No active tasks for this day",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tabType == "Done"
                  ? "Complete a task to see it here."
                  : tabType == "Overdue"
                      ? "Keep studying to stay on track!"
                      : "Tap + to add a task, or pick another day.",
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final task = filtered[index];
        return TaskCard(
          task: task,
          subjectColor: subjectColors[task.subjectId],
          onEdit: () => _editTask(context, task),
          onDelete: () => _deleteTask(context, task),
          onCompleted: (_) => _toggleTask(task),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SubjectModel>>(
      stream: subjectService.getSubjects(),
      builder: (context, subjectSnap) {
        final subjects = subjectSnap.data ?? [];
        final Map<String, Color> subjectColors = {
          for (final s in subjects) s.id: Color(s.color)
        };

        return StreamBuilder<List<TaskModel>>(
          stream: taskService.getTasks(),
          builder: (context, taskSnap) {
            final tasks = taskSnap.data ?? [];
            final now = DateTime.now();

            int receivedCount = 0;
            for (final task in tasks) {
              final taskTime = _getTaskDateTime(task);
              if (taskTime != null) {
                final rem = taskTime.subtract(const Duration(minutes: 15));
                if (rem.isBefore(now)) receivedCount++;
              }
            }

            final selDateStr = _dateStr(selectedDay);
            final bool showCalendar = _tabController.index == 0;

            return Container(
              decoration: AppColors.getBackgroundDecoration(),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text("Study Schedule"),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: Badge(
                        label: Text(receivedCount.toString()),
                        isLabelVisible: receivedCount > 0,
                        child: const Icon(Icons.notifications),
                      ),
                      onPressed: () => _showNotificationsDialog(context, tasks),
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(
                        text:
                            "Active (${tasks.where((t) => !t.completed && !_isTaskOverdue(t)).length})",
                      ),
                      Tab(
                        text:
                            "Done (${tasks.where((t) => t.completed).length})",
                      ),
                      Tab(
                        text:
                            "Overdue (${tasks.where((t) => _isTaskOverdue(t)).length})",
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    // ── Weekly Calendar Strip (Only for Active Tab) ──────────
                    if (showCalendar) _buildWeeklyStrip(tasks),

                    // ── Search + Filter bar ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (v) =>
                                  setState(() => searchQuery = v),
                              decoration: InputDecoration(
                                hintText: "Search tasks...",
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.textSecondary,
                                ),
                                suffixIcon: searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() => searchQuery = "");
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.card,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: selectedFilter != "All"
                                  ? AppColors.primary.withAlpha(20)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: selectedFilter != "All"
                                  ? Border.all(
                                      color: AppColors.primary, width: 1.5)
                                  : null,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedFilter,
                                icon: const Icon(
                                    Icons.filter_list,
                                    size: 20),
                                onChanged: (v) {
                                  setState(() {
                                    selectedFilter = v ?? "All";
                                  });
                                },
                                items: <String>[
                                  'All',
                                  'High',
                                  'Medium',
                                  'Low',
                                ]
                                    .map((v) => DropdownMenuItem(
                                        value: v, child: Text(v)))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Tab views ──────────────────────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _taskList(
                            context,
                            tasks,
                            subjectColors,
                            "Active",
                            taskSnap,
                            selectedDateStr: selDateStr,
                          ),
                          _taskList(
                            context,
                            tasks,
                            subjectColors,
                            "Done",
                            taskSnap,
                          ),
                          _taskList(
                            context,
                            tasks,
                            subjectColors,
                            "Overdue",
                            taskSnap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                  onPressed: () => _addTask(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
