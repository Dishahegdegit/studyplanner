import 'package:flutter/material.dart'; //for flutter widgets
import '../core/auth_gate.dart';  //next screen to navigate
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2)); //wait 2 seconds and continue

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()), //creating new page whose widget is auth gate
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightBordeaux,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: AppColors.alabasterGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Study Planner',
              style: TextStyle(
                color: AppColors.alabasterGrey,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan. Study. Succeed.',
              style: TextStyle(
                color: AppColors.rosyGranite,
                fontSize: 15,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: AppColors.alabasterGrey,
            ),
          ],
        ),
      ),
    );
  }
}