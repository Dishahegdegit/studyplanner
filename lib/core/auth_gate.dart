import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/login_screen.dart';
import '../screens/bottom_nav_screen.dart';
import '../utils/app_colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // idTokenChanges() is more reliable than authStateChanges() —
      // it fires immediately with the persisted user on cold start.
      stream: FirebaseAuth.instance.idTokenChanges(),
      // Seed with currentUser so we never show a false null on startup.
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.lobsterPink,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const BottomNavScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
