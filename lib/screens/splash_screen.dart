import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'bottom_nav_screen.dart';
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
    // Show splash for a brief moment, then check login state.
    // Firebase.initializeApp() is already done in main() before runApp(),
    // so currentUser is fully loaded and reliable by the time we get here.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Direct synchronous check — no streams, no listeners, no race conditions.
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Session exists on device — go straight to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      // No session — show login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.getBackgroundDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                'Study Planner',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan. Study. Succeed.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}