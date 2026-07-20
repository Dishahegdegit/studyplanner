import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class TimerCircle extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  const TimerCircle({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  String formatTime() {
    final minutes = secondsLeft ~/ 60;
    final seconds = secondsLeft % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = secondsLeft / totalSeconds;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: AppColors.cardSecondary.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.lobsterPink,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.lobsterPink,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                formatTime(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ThemeManager.isDark ? Colors.white : Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Focus Time",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
