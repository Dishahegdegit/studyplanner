import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/login_screen.dart';
import '../screens/bottom_nav_screen.dart';
import '../utils/app_colors.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _sub;
  bool _showLogin = false;
  bool _isLoggedIn = false;
  Timer? _authTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  void _checkInitialAuth() {
    // 1. Synchronous check: if user is already cached in memory, go home immediately
    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        _isLoggedIn = true;
      });
      return;
    }

    // 2. Otherwise listen to the token/auth state changes
    _sub = FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user != null) {
        _authTimer?.cancel();
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _showLogin = false;
          });
        }
      } else {
        // If user is null, don't show the login screen instantly.
        // Give the native client 3 seconds to load/decrypt the credentials.
        _authTimer?.cancel();
        _authTimer = Timer(const Duration(milliseconds: 3000), () {
          if (mounted) {
            setState(() {
              _isLoggedIn = false;
              _showLogin = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const BottomNavScreen();
    }

    if (_showLogin) {
      return const LoginScreen();
    }

    // Show loading while auth resolves
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.lobsterPink,
        ),
      ),
    );
  }
}
