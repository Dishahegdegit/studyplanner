import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/dashboard_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

final ProfileService profileService =
ProfileService();

final DashboardService dashboardService =
DashboardService();

int subjects = 0;
int tasks = 0;
int completed = 0;

bool loading = true;

@override
void initState() {
super.initState();
loadData();
}

Future<void> loadData() async {

subjects =
await dashboardService.getSubjectCount();

tasks =
await dashboardService.getTaskCount();

completed =
await dashboardService.getCompletedCount();

setState(() {
loading = false;
});
}

@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor: AppColors.background,

appBar: AppBar(
title: const Text("Profile"),
),

body: loading
? const Center(
child:
CircularProgressIndicator(),
)
: ListView(

padding:
const EdgeInsets.all(20),

children: [

const SizedBox(height: 10),

CircleAvatar(
radius: 55,
backgroundColor:
AppColors.primary,
child: const Icon(
Icons.person,
size: 60,
color: Colors.white,
),
),

const SizedBox(height: 20),

Center(
child: Text(
profileService.email,
style:
AppStyles.title,
),
),

const SizedBox(height: 30),

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(

children: [

ListTile(
leading:
const Icon(
Icons.menu_book,
color: Colors.indigo,
),
title:
const Text(
"Subjects",
),
trailing: Text(
subjects
.toString(),
style:
const TextStyle(
fontWeight:
FontWeight
.bold,
fontSize:
18,
),
),
),

const Divider(),

ListTile(
leading:
const Icon(
Icons.assignment,
color:
Colors.orange,
),
title:
const Text(
"Tasks",
),
trailing: Text(
tasks
.toString(),
style:
const TextStyle(
fontWeight:
FontWeight
.bold,
fontSize:
18,
),
),
),

const Divider(),

ListTile(
leading:
const Icon(
Icons.check_circle,
color:
Colors.green,
),
title:
const Text(
"Completed",
),
trailing: Text(
completed
.toString(),
style:
const TextStyle(
fontWeight:
FontWeight
.bold,
fontSize:
18,
),
),
),
],
),
),
),

const SizedBox(height: 25),
  Card(
    child: Column(
      children: [

        ListTile(
          leading: Icon(
            Icons.dark_mode,
            color: ThemeManager.isDark ? Colors.amber : Colors.deepPurple,
          ),
          title: const Text(
            "Dark Mode",
          ),
          trailing: Switch(
            value: ThemeManager.isDark,
            onChanged: (value) {
              setState(() {
                ThemeManager.toggleTheme();
              });
            },
          ),
        ),

        const Divider(height: 1),

        ListTile(
          leading: const Icon(
            Icons.notifications,
            color: Colors.orange,
          ),
          title: const Text(
            "Notifications",
          ),

          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
          ),
        ),

        const Divider(height: 1),

        const ListTile(
          leading: Icon(
            Icons.info,
            color: Colors.teal,
          ),
          title: Text(
            "About Study Planner",
          ),
          subtitle: Text(
            "Version 1.0",
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 30),

  SizedBox(
    height: 50,
    child: ElevatedButton.icon(

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      icon: const Icon(Icons.logout),

      label: const Text(
        "Logout",
      ),

      onPressed: () async {

        bool? logout = await showDialog(

          context: context,

          builder: (context) {

            return AlertDialog(

              title: const Text(
                "Logout",
              ),

              content: const Text(
                "Are you sure you want to logout?",
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
                    "Logout",
                  ),
                ),
              ],
            );
          },
        );

        if (logout == true) {
          await profileService.logout();
        }
      },
    ),
  ),

  const SizedBox(height: 40),
],
),
);
}
}