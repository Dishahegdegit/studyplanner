import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'schedule_screen.dart';
import 'subjects_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import '../utils/app_colors.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int _selectedIndex = 0; //home page

  final List<Widget> _pages = [
    const HomeScreen(),
     ScheduleScreen(),
    SubjectsScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.6),
          backgroundColor: AppColors.card,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Schedule",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Subjects",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Statistics",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}