import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/bottom_nav_screen.dart';
import 'utils/app_theme.dart';
import 'services/notification_service.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file for API keys
  await dotenv.load(fileName: '.env');
  AIService.apiKey = dotenv.env['GROQ_API_KEY'];

  // Initialize Firebase FIRST — must be fully done before reading currentUser
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications (can happen after Firebase)
  await NotificationService.initialize();

  // Determine the starting screen AFTER Firebase is fully ready
  // This is the exact same approach as the working reference project
  final user = FirebaseAuth.instance.currentUser;

  runApp(StudyPlannerApp(isLoggedIn: user != null));
}

class StudyPlannerApp extends StatelessWidget {
  final bool isLoggedIn;

  const StudyPlannerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Study Planner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          // If already logged in → go straight to home, skip splash entirely
          // If not logged in → show splash which routes to login
          home: isLoggedIn ? const BottomNavScreen() : const SplashScreen(),
        );
      },
    );
  }
}