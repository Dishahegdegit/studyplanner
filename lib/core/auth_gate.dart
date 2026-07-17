import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/bottom_nav_screen.dart';
import '../utils/app_colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>( //to listen to the authentication stream provided by AuthService

      stream: AuthService().userChanges, //constantly waits for updates from firebase
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) { //if firebase hasn't answered yet
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

        return const LoginScreen(); //no user. keep login page open
      },
    );
  }
}
