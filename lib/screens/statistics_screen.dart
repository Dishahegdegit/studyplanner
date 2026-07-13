import 'package:flutter/material.dart';

import '../services/statistics_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/progress_pie_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState
    extends State<StatisticsScreen> {

final StatisticsService statisticsService =
StatisticsService();

int subjects = 0;
int tasks = 0;
int completed = 0;
int pending = 0;

bool loading = true;

@override
void initState() {
  super.initState();
  loadStatistics();
}

Future<void> loadStatistics() async {

   subjects =
   await statisticsService.subjectCount();

  tasks = await statisticsService.taskCount();

completed = await statisticsService.completedCount();

pending = await statisticsService.pendingCount();

setState(() {
 loading = false;
   }
 );
}

double get progress {

if (tasks == 0) {
return 0;
}

return completed / tasks;
}

@override
Widget build(BuildContext context) {

  return Scaffold(

 backgroundColor: AppColors.background,

 appBar: AppBar(
 title: const Text("Statistics"),
 ),

 body: loading
 ? const Center(
 child:
 CircularProgressIndicator(),
 )
: RefreshIndicator(

    onRefresh: loadStatistics,

child: ListView(

padding:
const EdgeInsets.all(20),

children: [

Text(
"Study Progress", style: AppStyles.heading,
),

const SizedBox(
height: 8,
),

Text(
"Track your learning journey",
style:
AppStyles.subtitle,
),

const SizedBox(
height: 25,
),

Card(
child: Padding(
padding:
const EdgeInsets.all(
20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
"Overall Progress",
style:
AppStyles.title,
),

const SizedBox(
height: 20,
),

LinearProgressIndicator(
value: progress,
minHeight: 12,
borderRadius:
BorderRadius
.circular(
20),
backgroundColor:
Colors.grey
.shade300,
color:
AppColors.primary,
),

const SizedBox(
height: 15,
),

Center(
child: Text(
"${(progress * 100).toStringAsFixed(0)}% Completed",
style: const TextStyle(
fontSize: 18,
fontWeight:
FontWeight
.bold,
),
),
),
],
),
),
),

const SizedBox(
height: 25,
),

ProgressPieChart(
completed:
completed,
pending:
pending,
),

const SizedBox(
height: 25,
),
  Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            "Study Overview",
            style: AppStyles.title,
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: CircleAvatar(
              backgroundColor:
              Colors.indigo.shade100,
              child: const Icon(
                Icons.menu_book,
                color: Colors.indigo,
              ),
            ),
            title: const Text("Subjects"),
            trailing: Text(
              subjects.toString(),
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const Divider(),

          ListTile(
            leading: CircleAvatar(
              backgroundColor:
              Colors.orange.shade100,
              child: const Icon(
                Icons.assignment,
                color: Colors.orange,
              ),
            ),
            title: const Text("Total Tasks"),
            trailing: Text(
              tasks.toString(),
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const Divider(),

          ListTile(
            leading: CircleAvatar(
              backgroundColor:
              Colors.green.shade100,
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
            title: const Text("Completed"),
            trailing: Text(
              completed.toString(),
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const Divider(),

          ListTile(
            leading: CircleAvatar(
              backgroundColor:
              Colors.red.shade100,
              child: const Icon(
                Icons.pending_actions,
                color: Colors.red,
              ),
            ),
            title: const Text("Pending"),
            trailing: Text(
              pending.toString(),
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 18,
              ),
            ),
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
        children: [

          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 55,
          ),

          const SizedBox(height: 15),

          Text(
            "Completion Rate",
            style: AppStyles.title,
          ),

          const SizedBox(height: 10),

          Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 42,
              fontWeight:
              FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            completed == tasks
                ? "Fantastic! You're on track."
                : "Keep studying to reach your weekly goal!",
            textAlign: TextAlign.center,
            style: AppStyles.subtitle,
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