import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_card.dart';
import '../utils/app_colors.dart';

class ScheduleScreen extends StatelessWidget {
ScheduleScreen({super.key});

final TaskService taskService = TaskService();

Future<void> _addTask(BuildContext context) async {
final Map<String, dynamic>? result =
await showDialog<Map<String, dynamic>>(
context: context,
builder: (_) => const AddTaskDialog(),
);

if (result == null) return;

 TaskModel task = TaskModel(
 id: '',    //firestore generates id automatically
 title: result['title'],
 subjectId: result['subjectId'],
 subjectName: result['subjectName'],
 date: result['date'],
 startTime: result['startTime'],
 endTime: result['endTime'],
 priority: result['priority'],
 completed: false,
);

 await taskService.addTask(task);
}

Future<void> _editTask(BuildContext context, TaskModel task,) async {

final Map<String, dynamic>? result =
 await showDialog<Map<String, dynamic>>(
 context: context,
 builder: (_) => AddTaskDialog(
 task: task,       //sends the existing task into the dialog.


 ),
);

if (result == null) return;

TaskModel updatedTask = TaskModel(
id: task.id,
title: result['title'],
subjectId: result['subjectId'],
subjectName: result['subjectName'],
date: result['date'],
startTime: result['startTime'],
endTime: result['endTime'],
priority: result['priority'],
completed: task.completed,
);

await taskService.updateTask(updatedTask);
}

Future<void> _deleteTask(String id) async {
await taskService.deleteTask(id);
}

Future<void> _toggleTask(TaskModel task) async {
await taskService.toggleTaskCompletion(
task.id,
!task.completed,
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: AppColors.background,

appBar: AppBar(
title: const Text("Study Schedule"),
centerTitle: true,
  backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
),

body: StreamBuilder<List<TaskModel>>(
stream: taskService.getTasks(),

builder: (context, snapshot) {

if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(
snapshot.error.toString(),
),
);
}

final tasks = snapshot.data ?? [];

if (tasks.isEmpty) {
return const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [

Icon(
Icons.event_note,
size: 80,
color: Colors.grey,
),

SizedBox(height: 20),

Text(
"No Tasks Yet",
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

SizedBox(height: 10),

Text(
"Tap + to add your first study task.",
style: TextStyle(
color: Colors.grey,
),
),

],
),
);
}

return ListView.builder(
padding: const EdgeInsets.all(20),
itemCount: tasks.length,

itemBuilder: (context, index) {

final task = tasks[index];
return TaskCard(
  task: task,

  onEdit: () {
    _editTask(
      context,
      task,
    );
  },

  onDelete: () async {
    final bool? delete =
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Delete Task",
        ),
        content: Text(
          "Are you sure you want to delete '${task.title}'?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              "Cancel",
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text(
              "Delete",
            ),
          ),
        ],
      ),
    );

    if (delete == true) {
      _deleteTask(task.id);
    }
  },

  onCompleted: (value) {
    _toggleTask(task);
  },
);
},
);
},
),

  floatingActionButton: FloatingActionButton(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    child: const Icon(Icons.add),
    onPressed: () {
      _addTask(context);
    },
  ),
);
}
}