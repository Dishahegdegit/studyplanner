import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/dashboard_card.dart';
import 'pomodoro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final DashboardService dashboardService = DashboardService();

int subjects = 0;
int tasks = 0;
int completed = 0;
int pending = 0;

bool loading = true;

@override
void initState() {
  super.initState();
   loadDashboard();
}

Future<void> loadDashboard() async {
subjects = await dashboardService.getSubjectCount();
tasks = await dashboardService.getTaskCount();
completed = await dashboardService.getCompletedCount();
pending = await dashboardService.getPendingCount();

setState(() {
   loading = false;
  });
}

double get progress {
   if (tasks == 0) return 0;

 return completed / tasks;
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

appBar: AppBar(
title: const Text("Study Planner"),
),

body: loading
 ? const Center(
 child: CircularProgressIndicator(),
 )
: RefreshIndicator(
onRefresh: loadDashboard,
child: ListView(
padding: const EdgeInsets.all(20),
children: [

Text(
"Welcome Back 👋",
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
color: Colors.indigo,
),

DashboardCard(
icon: Icons.assignment,
title: "Tasks",
value: tasks.toString(),
color: Colors.orange,
),

DashboardCard(
icon: Icons.check_circle,
title: "Completed",
value: completed.toString(),
color: Colors.green,
),

DashboardCard(
icon: Icons.pending_actions,
title: "Pending",
value: pending.toString(),
color: Colors.red,
),
],
),

const SizedBox(height: 30),

InkWell(            //makes the widget clickable.
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

gradient: const LinearGradient(
colors: [
Color(0xFFFF8A00),
Color(0xFFFF5F00),
],
),

boxShadow: [
BoxShadow(
color: Colors.orange,
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
color: Colors.white24,
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
"🍅 Start Focus Session",
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
color: Colors.white70,
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
  Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            "Weekly Progress",
            style: AppStyles.title,
          ),

          const SizedBox(height: 20),

          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius:
            BorderRadius.circular(20),
            backgroundColor:
            Colors.grey.shade300,
            color: AppColors.primary,
          ),

          const SizedBox(height: 15),

          Text(
            "${(progress * 100).toStringAsFixed(0)}% Completed",
            style: AppStyles.subtitle,
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 25),

  Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            "Today's Summary",
            style: AppStyles.title,
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(
              Icons.menu_book,
              color: Colors.indigo,
            ),
            title: const Text("Subjects"),
            trailing: Text(
              subjects.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.assignment,
              color: Colors.orange,
            ),
            title: const Text("Tasks"),
            trailing: Text(
              tasks.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: const Text("Completed"),
            trailing: Text(
              completed.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.pending_actions,
              color: Colors.red,
            ),
            title: const Text("Pending"),
            trailing: Text(
              pending.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 30),
],
),
),
);
}
}