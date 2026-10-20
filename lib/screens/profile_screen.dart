import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/dashboard_service.dart';
import 'login_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService profileService = ProfileService();
  final DashboardService dashboardService = DashboardService();

  bool loading = true;
  bool isEditing = false;

  String name = "";
  String age = "";
  String college = "";
  String course = "";

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController courseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(profileService.currentUser!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        name = data['name'] ?? "";
        age = data['age'] ?? "";
        college = data['college'] ?? "";
        course = data['course'] ?? "";

        nameCtrl.text = name;
        ageCtrl.text = age;
        collegeCtrl.text = college;
        courseCtrl.text = course;
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  Widget _buildDetailBox(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textSecondary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
      IconData icon, Color color, String title, String subtitle) {
    final bool isDark = ThemeManager.isDark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(isDark ? 45 : 20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.linen : color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    collegeCtrl.dispose();
    courseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      name.isNotEmpty ? name : "Study Planner User",
                      style: AppStyles.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      profileService.email,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isEditing)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Personal Details",
                                  style: AppStyles.title,
                                ),
                                Icon(
                                  Icons.edit_off,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.linen
                                      : AppColors.textMuted,
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildDetailField("Full Name", nameCtrl),
                            _buildDetailField(
                              "Age",
                              ageCtrl,
                              keyboardType: TextInputType.number,
                            ),
                            _buildDetailField("College/School", collegeCtrl),
                            _buildDetailField("Course/Class", courseCtrl),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      nameCtrl.text = name;
                                      ageCtrl.text = age;
                                      collegeCtrl.text = college;
                                      courseCtrl.text = course;
                                      isEditing = false;
                                    });
                                  },
                                  child: const Text("Cancel"),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        name = nameCtrl.text.trim();
                                        age = ageCtrl.text.trim();
                                        college = collegeCtrl.text.trim();
                                        course = courseCtrl.text.trim();
                                        isEditing = false;
                                      });
                                      await profileService.saveUserDetails(
                                        name: name,
                                        age: age,
                                        college: college,
                                        course: course,
                                      );
                                    },
                                    child: const Text("Save"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Personal Details",
                                  style: AppStyles.title,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.lobsterPink),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildDetailBox(
                              "Full Name",
                              name.isEmpty ? "Not set" : name,
                            ),
                            _buildDetailBox(
                                "Age", age.isEmpty ? "Not set" : age),
                            _buildDetailBox(
                              "College / School",
                              college.isEmpty ? "Not set" : college,
                            ),
                            _buildDetailBox(
                              "Course / Class",
                              course.isEmpty ? "Not set" : course,
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
                            color: ThemeManager.isDark
                                ? AppColors.almondSilk
                                : AppColors.winePlum,
                          ),
                          title: const Text("Dark Mode"),
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
                          leading: Icon(
                            Icons.info,
                            color: AppColors.vividPink,
                          ),
                          title: const Text("About App"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    color: Theme.of(context).cardColor,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Header Gradient
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 24, horizontal: 16),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.primary
                                                    .withAlpha(180)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: const Column(
                                            children: [
                                              Icon(
                                                Icons.school_rounded,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Study Planner",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Version 1.0.0",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Dialog Content
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 20, 20, 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Your ultimate learning companion designed to boost focus, structure your study schedule, and track academic achievements.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              // Feature list
                                              _buildFeatureRow(
                                                  Icons.calendar_today_rounded,
                                                  AppColors.lobsterPink,
                                                  "Schedule & Tabs",
                                                  "Organize tasks by Active, Done & Overdue"),
                                              const SizedBox(height: 12),
                                              _buildFeatureRow(
                                                  Icons.timer_rounded,
                                                  AppColors.vividPink,
                                                  "Pomodoro Engine",
                                                  "Stay focused with customizable work sessions"),
                                              const SizedBox(height: 12),
                                              _buildFeatureRow(
                                                  Icons.bar_chart_rounded,
                                                  AppColors.almondSilk,
                                                  "Productivity Metrics",
                                                  "Analyze study hours and weekly progress"),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        // Close Button
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  "Close",
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.winePlum,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      onPressed: () async {
                        bool? logout = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                  "Are you sure you want to logout?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lobsterPink,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text("Logout"),
                                ),
                              ],
                            );
                          },
                        );

                        if (logout == true) {
                          await profileService.logout();
                          if (!mounted) return;
                          // Navigate to login and clear entire history
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }
}
