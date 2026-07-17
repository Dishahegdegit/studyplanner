import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? task;

  const AddTaskDialog({
    super.key,
    this.task,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
final SubjectService subjectService = SubjectService();

final TextEditingController titleController =
TextEditingController();

DateTime? selectedDate;
TimeOfDay? startTime;
TimeOfDay? endTime;

String priority = "Medium";
String? selectedSubjectId;

@override
void initState() {
super.initState();

if (widget.task != null) {
titleController.text = widget.task!.title;

selectedSubjectId = widget.task!.subjectId;

priority = widget.task!.priority;

selectedDate =
DateFormat("dd MMM yyyy").parse(widget.task!.date);

startTime = _stringToTime(widget.task!.startTime);

endTime = _stringToTime(widget.task!.endTime);
}
}

TimeOfDay _stringToTime(String time) {
final dt = DateFormat.jm().parse(time);

return TimeOfDay(
hour: dt.hour,
minute: dt.minute,
);
}

String formatDate(DateTime date) {
return DateFormat(
"dd MMM yyyy",
).format(date);
}

String formatTime(TimeOfDay time) {
final now = DateTime.now();

final dt = DateTime(
now.year,
now.month,
now.day,
time.hour,
time.minute,
);

return DateFormat.jm().format(dt);
}

Future<void> pickDate() async {
final date = await showDatePicker(
context: context,
firstDate: DateTime.now(),
lastDate: DateTime(2035),
initialDate: selectedDate ?? DateTime.now(),
);

if (date != null) {
setState(() {
selectedDate = date;
});
}
}

Future<void> pickStartTime() async {
final time = await showTimePicker(
context: context,
initialTime:
startTime ?? TimeOfDay.now(),
);

if (time != null) {
setState(() {
startTime = time;
});
}
}

Future<void> pickEndTime() async {
final time = await showTimePicker(
context: context,
initialTime:
endTime ??
const TimeOfDay(
hour: 10,
minute: 0,
),
);

if (time != null) {
setState(() {
endTime = time;
});
}
}

@override
Widget build(BuildContext context) {
final bool isDark = Theme.of(context).brightness == Brightness.dark;

return StreamBuilder<List<SubjectModel>>(

stream: subjectService.getSubjects(),

builder: (context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {

return const AlertDialog(
content: SizedBox(
height: 100,
child: Center(
child:
CircularProgressIndicator(),
),
),
);
}

final subjects = snapshot.data ?? [];

if (subjects.isNotEmpty &&
selectedSubjectId == null) {
selectedSubjectId = subjects.first.id;
}

return AlertDialog(

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),

title: Text(
widget.task == null
? "Add Study Task"
: "Edit Study Task",
),

content: SizedBox(
width: 420,

child: SingleChildScrollView(

child: Column(

children: [

TextField(
controller: titleController,
decoration:
const InputDecoration(
labelText:
"Task Title",
border:
OutlineInputBorder(),
),
),

const SizedBox(height: 18),

DropdownButtonFormField<String>(
  initialValue: selectedSubjectId,

decoration:
const InputDecoration(
labelText:
"Subject",
border:
OutlineInputBorder(),
),

items: subjects.map((subject) {

return DropdownMenuItem(

value: subject.id,

child: Text(
subject.name,
),

);

}).toList(),

onChanged: (value) {

setState(() {

selectedSubjectId =
value;

});

},
),

const SizedBox(height: 18),
  ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    tileColor: AppColors.card,
    leading: Icon(
      Icons.calendar_month,
      color: isDark ? AppColors.linen : AppColors.lobsterPink,
    ),
    title: Text(
      selectedDate == null
          ? "Select Date"
          : formatDate(selectedDate!),
    ),
    trailing: Icon(
      Icons.arrow_drop_down,
      color: isDark ? AppColors.linen : AppColors.textSecondary,
    ),
    onTap: pickDate,
  ),

  const SizedBox(height: 12),

  ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    tileColor: AppColors.card,
    leading: Icon(
      Icons.access_time,
      color: isDark ? AppColors.linen : AppColors.lobsterPink,
    ),
    title: Text(
      startTime == null
          ? "Start Time"
          : formatTime(startTime!),
    ),
    trailing: Icon(
      Icons.arrow_drop_down,
      color: isDark ? AppColors.linen : AppColors.textSecondary,
    ),
    onTap: pickStartTime,
  ),

  const SizedBox(height: 12),

  ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    tileColor: AppColors.card,
    leading: Icon(
      Icons.schedule,
      color: isDark ? AppColors.linen : AppColors.winePlum,
    ),
    title: Text(
      endTime == null
          ? "End Time"
          : formatTime(endTime!),
    ),
    trailing: Icon(
      Icons.arrow_drop_down,
      color: isDark ? AppColors.linen : AppColors.textSecondary,
    ),
    onTap: pickEndTime,
  ),

  const SizedBox(height: 18),

DropdownButtonFormField<String>(
    initialValue: priority,
    decoration: const InputDecoration(
      labelText: "Priority",
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(
        value: "High",
        child: Text("High"),
      ),
      DropdownMenuItem(
        value: "Medium",
        child: Text("Medium"),
      ),
      DropdownMenuItem(
        value: "Low",
        child: Text("Low"),
      ),
    ],
    onChanged: (value) {
      setState(() {
        priority = value!;
      });
    },
  ),

  const SizedBox(height: 25),

  SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lobsterPink,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        if (titleController.text.trim().isEmpty ||
            selectedSubjectId == null ||
            selectedDate == null ||
            startTime == null ||
            endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please fill all fields.",
              ),
            ),
          );
          return;
        }

        final SubjectModel selectedSubject = subjects.firstWhere(
          (subject) => subject.id == selectedSubjectId,
        );

        await _scheduleReminder(
          title: titleController.text.trim(),
          subjectName: selectedSubject.name,
          date: selectedDate!,
          start: startTime!,
          taskId: widget.task?.id,
        );

        if (!context.mounted) return;

        Navigator.pop(
          context,
          {
            "title": titleController.text.trim(),
            "subjectId": selectedSubject.id,
            "subjectName": selectedSubject.name,
            "date": formatDate(selectedDate!),
            "startTime": formatTime(startTime!),
            "endTime": formatTime(endTime!),
            "priority": priority,
          },
        );
      },
      child: Text(
        widget.task == null
            ? "Add Task"
            : "Update Task",
      ),
    ),
  ),
],
),
),
),
);
},
);
}

  /// Schedules a local notification 15 minutes before the task starts.
  /// Silently skips if the reminder time is already in the past.
  Future<void> _scheduleReminder({
    required String title,
    required String subjectName,
    required DateTime date,
    required TimeOfDay start,
    String? taskId,
  }) async {
    try {
      // Build the full start DateTime from picked date + time
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        start.hour,
        start.minute,
      );

      // Reminder fires 15 minutes before start
      final reminderTime = startDateTime.subtract(const Duration(minutes: 15));

      // Don't schedule if the time has already passed
      if (reminderTime.isBefore(DateTime.now())) return;

      // Use a stable int ID: mix date + hour + minute so edits
      // to the same task replace the old notification.
      final notifId = Object.hash(
        date.day,
        date.month,
        date.year,
        start.hour,
        start.minute,
        title,
      ).abs() % 100000; // keep within int32 safe range

      // Cancel any previous notification for this slot (edit case)
      NotificationService.cancelNotification(notifId);

      await NotificationService.scheduleNotification(
        id: notifId,
        title: '⏰ Upcoming Study Session',
        body: '$title · $subjectName starts in 15 minutes!',
        scheduledTime: reminderTime,
      );
    } catch (_) {
      // Fail silently — notification is non-critical
    }
  }

@override
void dispose() {
  titleController.dispose();
  super.dispose();
}
}
